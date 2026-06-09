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

    // MARK: - Zonas

    func zoneRangeText(for zone: Zone) -> String? {
        guard let threshold = profile.thresholdHR, let max = profile.maxHR else { return nil }
        return FrielZoneCalculator.rangeText(for: zone, thresholdHR: threshold, maxHR: max)
    }
}
