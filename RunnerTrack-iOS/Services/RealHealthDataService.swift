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
