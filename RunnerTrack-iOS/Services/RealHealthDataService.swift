import Foundation
import HealthKit

/// Implementación real sobre HealthKit.
/// Permisos: se solicitan en el primer acceso a datos, nunca en init (CLAUDE.md §3).
/// Cualquier fallo (sin permisos, sin datos, HealthKit no disponible) devuelve nil — nunca crash.
final class RealHealthDataService: HealthDataService {
    private let store = HKHealthStore()
    private var authorizationRequested = false

    private var readTypes: Set<HKObjectType> {
        [
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.stepCount),
            HKCategoryType(.sleepAnalysis),
            HKWorkoutType.workoutType(),
        ]
    }

    /// Solicita permisos la primera vez que se necesitan datos
    private func ensureAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        if authorizationRequested { return true }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            authorizationRequested = true
            return true
        } catch {
            return false
        }
    }

    // MARK: - HealthDataService

    func getRestingHR() async -> Int? {
        guard let sample = await latestQuantitySample(.restingHeartRate) else { return nil }
        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        return Int(bpm.rounded())
    }

    func getHRV() async -> Double? {
        guard let sample = await latestQuantitySample(.heartRateVariabilitySDNN) else { return nil }
        return sample.quantity.doubleValue(for: .secondUnit(with: .milli))
    }

    /// Pasos acumulados de hoy
    func getSteps() async -> Int? {
        guard await ensureAuthorization() else { return nil }
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .now)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(.stepCount),
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                let steps = statistics?.sumQuantity()?.doubleValue(for: .count())
                continuation.resume(returning: steps.map { Int($0) })
            }
            store.execute(query)
        }
    }

    /// Horas dormidas en las últimas 24 h (suma de tramos asleep)
    func getSleepHours() async -> Double? {
        guard await ensureAuthorization() else { return nil }
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKCategoryType(.sleepAnalysis),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }
                let asleepValues = Set(HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue))
                let seconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: seconds > 0 ? seconds / 3600.0 : nil)
            }
            store.execute(query)
        }
    }

    /// Entrenos de running de los últimos 90 días, ordenados del más reciente al más antiguo
    func getRecentWorkouts(limit: Int) async -> [HealthWorkout] {
        guard await ensureAuthorization() else { return [] }
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: ninetyDaysAgo, end: .now)
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: predicate,
                limit: limit,
                sortDescriptors: sort
            ) { _, samples, _ in
                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }
                let result: [HealthWorkout] = workouts
                    .filter { $0.workoutActivityType == .running }
                    .compactMap { workout -> HealthWorkout? in
                        let durationMin = Int(workout.duration / 60)
                        guard durationMin >= 5 else { return nil }
                        let distanceKm = workout.totalDistance
                            .map { $0.doubleValue(for: .meterUnit(with: .kilo)) }
                        let avgHR = workout.statistics(for: HKQuantityType(.heartRate))
                            .flatMap { stats -> Int? in
                                guard let qty = stats.averageQuantity() else { return nil }
                                return Int(qty.doubleValue(for: HKUnit(from: "count/min")).rounded())
                            }
                        return HealthWorkout(
                            id: workout.uuid,
                            date: workout.startDate,
                            durationMinutes: durationMin,
                            distanceKm: distanceKm,
                            avgHR: avgHR
                        )
                    }
                continuation.resume(returning: result)
            }
            self.store.execute(query)
        }
    }

    /// FC reposo de los últimos N días — una muestra por día
    func getDailyRestingHR(days: Int) async -> [(date: Date, bpm: Int)] {
        guard await ensureAuthorization() else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKQuantityType(.restingHeartRate),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: sort
            ) { _, samples, _ in
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }
                let bpmUnit = HKUnit.count().unitDivided(by: .minute())
                var byDay: [Date: Int] = [:]
                for sample in samples {
                    let day = Calendar.current.startOfDay(for: sample.endDate)
                    if byDay[day] == nil {
                        byDay[day] = Int(sample.quantity.doubleValue(for: bpmUnit).rounded())
                    }
                }
                let result = byDay
                    .map { (date: $0.key, bpm: $0.value) }
                    .sorted { $0.date < $1.date }
                continuation.resume(returning: result)
            }
            self.store.execute(query)
        }
    }

    // MARK: - Helpers

    /// Muestra más reciente de un tipo cuantitativo
    private func latestQuantitySample(_ identifier: HKQuantityTypeIdentifier) async -> HKQuantitySample? {
        guard await ensureAuthorization() else { return nil }

        return await withCheckedContinuation { continuation in
            let sort = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            let query = HKSampleQuery(
                sampleType: HKQuantityType(identifier),
                predicate: nil,
                limit: 1,
                sortDescriptors: sort
            ) { _, samples, _ in
                continuation.resume(returning: samples?.first as? HKQuantitySample)
            }
            store.execute(query)
        }
    }
}
