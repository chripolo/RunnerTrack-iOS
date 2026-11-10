import Foundation

@Observable
final class MetricsViewModel {
    private let healthService: HealthDataService

    var restingHR: Int?
    var hrv: Double?
    var alertLevel: AlertLevel = .green

    // Media personal de FC reposo — TODO: S5 — calcular desde DailyMetric histórico
    let personalMeanRestingHR = 48
    var restingAlertThreshold: Int { personalMeanRestingHR + 5 }

    init(healthService: HealthDataService) {
        self.healthService = healthService
    }

    func loadHealthData() async {
        async let resting = healthService.getRestingHR()
        async let variability = healthService.getHRV()
        (restingHR, hrv) = await (resting, variability)
        alertLevel = RulesEngine.evaluate(
            restingHR: restingHR,
            personalMeanRestingHR: personalMeanRestingHR,
            hrv: hrv
        )
    }

    // MARK: - Progresión ritmo Z2 (dataset de ejemplo)

    struct PacePoint: Identifiable {
        let id = UUID()
        let date: Date
        let secPerKm: Double
    }

    let targetPace: Double = 370

    let paceHistory: [PacePoint] = [
        PacePoint(date: MetricsViewModel.day(2026, 3, 21), secPerKm: 454),
        PacePoint(date: MetricsViewModel.day(2026, 3, 28), secPerKm: 448),
        PacePoint(date: MetricsViewModel.day(2026, 4, 5), secPerKm: 414),
        PacePoint(date: MetricsViewModel.day(2026, 4, 12), secPerKm: 416),
        PacePoint(date: MetricsViewModel.day(2026, 4, 26), secPerKm: 400),
        PacePoint(date: MetricsViewModel.day(2026, 5, 3), secPerKm: 406),
        PacePoint(date: MetricsViewModel.day(2026, 5, 5), secPerKm: 397),
        PacePoint(date: MetricsViewModel.day(2026, 5, 17), secPerKm: 380),
        PacePoint(date: MetricsViewModel.day(2026, 5, 31), secPerKm: 370),
    ]

    // MARK: - FC reposo de la última semana (mock)

    struct RestingHRPoint: Identifiable {
        let id = UUID()
        let day: String
        let bpm: Int
    }

    let restingHRWeek: [RestingHRPoint] = [
        RestingHRPoint(day: "Lun", bpm: 47),
        RestingHRPoint(day: "Mar", bpm: 48),
        RestingHRPoint(day: "Mié", bpm: 49),
        RestingHRPoint(day: "Jue", bpm: 47),
        RestingHRPoint(day: "Vie", bpm: 48),
        RestingHRPoint(day: "Sáb", bpm: 46),
        RestingHRPoint(day: "Dom", bpm: 48),
    ]

    // MARK: - Estadísticas acumuladas (dataset histórico)

    let totalDistanceKm = 168.0
    let totalTimeText = "18h 30m"
    let activeWeeks = 12
    let paceImprovementText = "-1'24\""
    let paceImprovementDetail = "7'34\" → 6'10\""

    // MARK: - Formato

    /// 370 → 6'10"
    static func paceString(_ secPerKm: Double) -> String {
        let total = Int(secPerKm.rounded())
        return "\(total / 60)'\(String(format: "%02d", total % 60))\""
    }

    private static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}
