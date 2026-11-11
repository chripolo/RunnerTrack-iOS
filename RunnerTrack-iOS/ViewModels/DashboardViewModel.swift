import Foundation

@Observable
final class DashboardViewModel {
    private let profile: UserProfile
    private let healthService: HealthDataService

    // Métricas de salud (Mock en DEBUG, HealthKit en RELEASE)
    var restingHR: Int?
    var hrv: Double?
    var alertLevel: AlertLevel = .green

    // Media personal de FC reposo — TODO: S5 — calcular desde DailyMetric histórico
    private let personalMeanRestingHR = 48

    /// Semana S01 desde el catálogo compartido
    let weekSessions = S01Catalog.sessions

    init(profile: UserProfile, healthService: HealthDataService) {
        self.profile = profile
        self.healthService = healthService
    }

    func loadHealthData() async {
        restingHR = await healthService.getRestingHR()
        hrv = await healthService.getHRV()
        alertLevel = RulesEngine.evaluate(
            restingHR: restingHR,
            personalMeanRestingHR: personalMeanRestingHR,
            hrv: hrv
        )
    }

    // MARK: - Saludo dinámico

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 6..<14: return "Buenos días"
        case 14..<21: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }

    var userName: String { profile.name }

    // MARK: - Carrera objetivo

    var raceName: String { profile.targetRace.rawValue }

    var raceDateText: String {
        profile.targetDate.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "es_ES")))
    }

    var daysUntilRace: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: profile.targetDate)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    // MARK: - Progreso semanal

    /// Km estimados del plan semanal (duración × ritmo Z2 del perfil)
    var plannedKm: Double {
        weekSessions
            .filter { $0.type != .rest }
            .reduce(0.0) { sum, t in
                guard let dur = t.durationMin else { return sum }
                return sum + Double(dur) * 60.0 / profile.initialPaceZ2
            }
    }

    /// Sesiones de running planificadas (sin descansos)
    var plannedSessionCount: Int {
        weekSessions.filter { $0.type != .rest }.count
    }

    /// Km completados desde TrainingSession en SwiftData
    func completedKm(from sessions: [TrainingSession]) -> Double {
        sessions.filter(\.completed).reduce(0.0) { sum, s in
            if let dist = s.distance { return sum + dist }
            guard let dur = s.actualDuration else { return sum }
            return sum + Double(dur) * 60.0 / profile.initialPaceZ2
        }
    }

    func completedCount(from sessions: [TrainingSession]) -> Int {
        sessions.filter(\.completed).count
    }

    /// Siguiente sesión con running (no descanso) que no esté completada
    func nextTemplate(completedDayIndexes: Set<Int>) -> SessionTemplate? {
        let todayIndex = (Calendar.current.component(.weekday, from: .now) + 5) % 7
        let upcoming = weekSessions
            .filter { $0.type != .rest && !completedDayIndexes.contains($0.dayIndex) }
        // primero las de hoy en adelante, luego las anteriores (wrap si toda la semana está hecha)
        return upcoming.min(by: {
            let a = ($0.dayIndex - todayIndex + 7) % 7
            let b = ($1.dayIndex - todayIndex + 7) % 7
            return a < b
        })
    }

    // MARK: - Zonas

    func zoneRangeText(for zone: Zone) -> String? {
        guard let threshold = profile.thresholdHR, let max = profile.maxHR else { return nil }
        return FrielZoneCalculator.rangeText(for: zone, thresholdHR: threshold, maxHR: max)
    }
}
