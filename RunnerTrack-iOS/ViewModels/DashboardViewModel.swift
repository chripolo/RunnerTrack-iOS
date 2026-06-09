import Foundation

// Sesión planificada para previsualización en dashboard.
// Plan S01 hardcodeado — TODO: S2 — generar desde el motor de reglas
struct PlannedSessionPreview: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let title: String
    let zone: Zone?              // nil = descanso
    let durationMin: Int?
    let detail: String
}

/// Rango de zona Friel listo para presentar
struct ZoneDisplay: Identifiable {
    let zone: Zone
    let name: String
    let rangeText: String
    var id: String { zone.rawValue }
}

@Observable
final class DashboardViewModel {
    private let profile: UserProfile
    private let healthService: HealthDataService

    // Métricas de salud (Mock en DEBUG, HealthKit en RELEASE)
    var restingHR: Int?
    var hrv: Double?

    init(profile: UserProfile, healthService: HealthDataService) {
        self.profile = profile
        self.healthService = healthService
    }

    func loadHealthData() async {
        restingHR = await healthService.getRestingHR()
        hrv = await healthService.getHRV()
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

    // MARK: - Zonas Friel
    // Límites inferiores según fórmulas CLAUDE.md §5 (umbral × factor, redondeado)

    var zoneDisplays: [ZoneDisplay] {
        guard let threshold = profile.thresholdHR else { return [] }
        let z2Low = Int((Double(threshold) * 0.85).rounded())
        let z3Low = Int((Double(threshold) * 0.90).rounded())
        let z4Low = Int((Double(threshold) * 0.95).rounded())
        return [
            ZoneDisplay(zone: .z1, name: "Recuperación", rangeText: "0–\(profile.zone1Max) bpm"),
            ZoneDisplay(zone: .z2, name: "Aeróbico", rangeText: "\(z2Low)–\(profile.zone2Max) bpm"),
            ZoneDisplay(zone: .z3, name: "Tempo", rangeText: "\(z3Low)–\(profile.zone3Max) bpm"),
            ZoneDisplay(zone: .z4, name: "Umbral", rangeText: "\(z4Low)–\(profile.zone4Max) bpm"),
            ZoneDisplay(zone: .z5, name: "Máximo", rangeText: "\(threshold)–\(profile.zone5Max) bpm"),
        ]
    }

    // MARK: - Semana S01 (hardcodeada)

    let weekSessions: [PlannedSessionPreview] = [
        PlannedSessionPreview(
            day: "Lunes", title: "Descanso", zone: nil, durationMin: nil,
            detail: "Día de recuperación total. Caminar está bien; correr, no."
        ),
        PlannedSessionPreview(
            day: "Martes", title: "Trote Z1 + Fuerza A", zone: .z1, durationMin: 40,
            detail: "Trote muy suave en Z1, conversación cómoda. Después, rutina de fuerza A: core y cadera."
        ),
        PlannedSessionPreview(
            day: "Miércoles", title: "Rodaje Z2", zone: .z2, durationMin: 50,
            detail: "Rodaje aeróbico en Z2. Mantener la FC dentro del rango — si sube, caminar."
        ),
        PlannedSessionPreview(
            day: "Jueves", title: "Trote Z1 + Fuerza B", zone: .z1, durationMin: 40,
            detail: "Trote regenerativo en Z1. Después, rutina de fuerza B: piernas y tobillos."
        ),
        PlannedSessionPreview(
            day: "Viernes", title: "Calidad Z3", zone: .z3, durationMin: 45,
            detail: "Sesión de tempo en Z3. Calentar 15', bloque central controlado, enfriar 10'."
        ),
        PlannedSessionPreview(
            day: "Sábado", title: "Descanso", zone: nil, durationMin: nil,
            detail: "Descanso antes de la tirada larga. Hidratación y sueño son el entreno de hoy."
        ),
        PlannedSessionPreview(
            day: "Domingo", title: "Tirada larga Z2", zone: .z2, durationMin: 75,
            detail: "La sesión clave de la semana. Ritmo cómodo en Z2 de principio a fin."
        ),
    ]
}
