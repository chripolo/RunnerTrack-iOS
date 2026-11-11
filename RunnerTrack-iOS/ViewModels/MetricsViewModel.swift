import Foundation

@Observable
final class MetricsViewModel {
    private let healthService: HealthDataService

    var restingHR: Int?
    var hrv: Double?
    var alertLevel: AlertLevel = .green

    let personalMeanRestingHR = 48
    var restingAlertThreshold: Int { personalMeanRestingHR + 5 }

    // MARK: - Progresión ritmo Z2 (calculado desde TrainingSession reales)

    struct PacePoint: Identifiable {
        let id = UUID()
        let date: Date
        let secPerKm: Double
    }

    var paceHistory: [PacePoint] = []
    var targetPace: Double = 363       // actualizado por updateWithSessions

    // Dominio dinámico del gráfico de ritmo
    var paceDomainMin: Double { max(300, (paceHistory.map(\.secPerKm).min() ?? 355) - 20) }
    var paceDomainMax: Double { min(600, (paceHistory.map(\.secPerKm).max() ?? 470) + 20) }

    // MARK: - FC reposo (HealthKit, últimos 7 días)

    struct RestingHRPoint: Identifiable {
        let id = UUID()
        let date: Date
        let bpm: Int
        var day: String {
            date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "es_ES")))
        }
    }

    var restingHRWeek: [RestingHRPoint] = []

    // MARK: - Volumen semanal

    struct WeeklyVolumePoint: Identifiable {
        let id = UUID()
        let weekStart: Date
        let km: Double
        var label: String {
            let d = Calendar.current.component(.day, from: weekStart)
            let m = Calendar.current.component(.month, from: weekStart)
            return "\(d)/\(m)"
        }
    }

    var weeklyVolume: [WeeklyVolumePoint] = []

    // MARK: - Estadísticas acumuladas

    var totalDistanceKm: Double = 0
    var totalTimeText: String = "—"
    var activeWeeks: Int = 0
    var paceImprovementText: String = "—"
    var paceImprovementDetail: String = "—"

    init(healthService: HealthDataService) {
        self.healthService = healthService
    }

    // MARK: - Carga de datos

    func loadHealthData() async {
        restingHR = await healthService.getRestingHR()
        hrv = await healthService.getHRV()
        alertLevel = RulesEngine.evaluate(
            restingHR: restingHR,
            personalMeanRestingHR: personalMeanRestingHR,
            hrv: hrv
        )
        let hrHistory = await healthService.getDailyRestingHR(days: 7)
        restingHRWeek = hrHistory.map { RestingHRPoint(date: $0.date, bpm: $0.bpm) }
    }

    /// Actualiza todas las métricas calculadas a partir de las TrainingSession en SwiftData
    func updateWithSessions(_ sessions: [TrainingSession], profile: UserProfile? = nil) {
        if let profile {
            targetPace = profile.goalTier.targetPace(for: profile.targetRace)
        }
        let completed = sessions.filter(\.completed)

        // Ritmo Z2 histórico
        paceHistory = completed
            .compactMap { session -> PacePoint? in
                let secPerKm: Double
                if let pace = session.avgPace, pace > 240 { // avgPace en seg/km, > 4 min/km
                    secPerKm = pace
                } else if let dist = session.distance, let dur = session.actualDuration, dist > 0.5 {
                    secPerKm = Double(dur) * 60.0 / dist
                } else {
                    return nil
                }
                // Filtro de cordura: 4–12 min/km
                guard secPerKm >= 240, secPerKm <= 720 else { return nil }
                return PacePoint(date: session.date, secPerKm: secPerKm)
            }
            .sorted { $0.date < $1.date }

        // Acumulado — total de sesiones completadas (90 días)
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: .now) ?? .now
        let recent = completed.filter { $0.date >= ninetyDaysAgo }
        totalDistanceKm = recent.compactMap(\.distance).reduce(0, +)
        let totalMins = recent.compactMap(\.actualDuration).reduce(0, +)
        totalTimeText = "\(totalMins / 60)h \(totalMins % 60)m"

        let weekStarts = Set(recent.map { PlanViewModel.mondayOfCurrentWeek(from: $0.date) })
        activeWeeks = weekStarts.count

        // Mejora de ritmo (primer vs último punto Z2)
        if paceHistory.count >= 2,
           let first = paceHistory.first,
           let last = paceHistory.last {
            let diff = last.secPerKm - first.secPerKm
            let sign = diff <= 0 ? "-" : "+"
            let absDiff = Int(abs(diff))
            paceImprovementText = "\(sign)\(absDiff / 60)'\(String(format: "%02d", absDiff % 60))\""
            paceImprovementDetail = "\(Self.paceString(first.secPerKm)) → \(Self.paceString(last.secPerKm))"
        } else {
            paceImprovementText = "—"
            paceImprovementDetail = "sin datos"
        }

        // Volumen por semana (últimas 12 semanas)
        let weekGroups = Dictionary(grouping: recent) { session in
            PlanViewModel.mondayOfCurrentWeek(from: session.date)
        }
        weeklyVolume = weekGroups
            .map { weekStart, group in
                WeeklyVolumePoint(weekStart: weekStart, km: group.compactMap(\.distance).reduce(0, +))
            }
            .sorted { $0.weekStart < $1.weekStart }
            .suffix(12)
            .map { $0 }
    }

    // MARK: - Formato

    static func paceString(_ secPerKm: Double) -> String {
        let total = Int(secPerKm.rounded())
        return "\(total / 60)'\(String(format: "%02d", total % 60))\""
    }
}
