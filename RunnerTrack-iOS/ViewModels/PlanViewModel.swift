import Foundation
import SwiftData

@Observable
final class PlanViewModel {
    private let profile: UserProfile
    private let healthService: HealthDataService
    private(set) var weekSessions: [TrainingSession] = []
    private(set) var isImporting = false
    private(set) var lastImportedCount: Int? = nil

    let templates = S01Catalog.sessions

    init(profile: UserProfile, healthService: HealthDataService) {
        self.profile = profile
        self.healthService = healthService
    }

    // MARK: - Persistencia de la semana

    /// Crea las TrainingSession de la semana actual en SwiftData si no existen aún
    func ensureWeekSessions(context: ModelContext) {
        let weekStart = Self.mondayOfCurrentWeek()
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else { return }

        let predicate = #Predicate<TrainingSession> { $0.date >= weekStart && $0.date < weekEnd }
        let existing = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []

        if existing.isEmpty {
            for template in templates {
                guard let date = Calendar.current.date(byAdding: .day, value: template.dayIndex, to: weekStart) else { continue }
                let session = TrainingSession(
                    date: date,
                    type: template.type,
                    plannedDuration: template.durationMin ?? 0,
                    plannedZone: template.zone ?? .z1
                )
                context.insert(session)
            }
            try? context.save()
            weekSessions = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []
        } else {
            weekSessions = existing
        }
    }

    func storedSession(for template: SessionTemplate) -> TrainingSession? {
        weekSessions.first { Self.dayIndex(of: $0.date) == template.dayIndex }
    }

    func isCompleted(_ template: SessionTemplate) -> Bool {
        storedSession(for: template)?.completed ?? false
    }

    func toggleCompleted(_ template: SessionTemplate, context: ModelContext) {
        guard let session = storedSession(for: template) else { return }
        session.completed.toggle()
        session.actualDuration = session.completed ? session.plannedDuration : nil
        try? context.save()
    }

    // MARK: - Importación desde HealthKit

    /// Lee workouts de running de los últimos 90 días y crea TrainingSession por cada día nuevo
    func importFromHealthKit(context: ModelContext) async {
        isImporting = true
        lastImportedCount = nil
        let workouts = await healthService.getRecentWorkouts(limit: 50)
        let count = WorkoutImporter.importWorkouts(workouts, into: context)
        // Recargar sesiones de la semana actual tras la importación
        let weekStart = Self.mondayOfCurrentWeek()
        guard let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else {
            isImporting = false
            lastImportedCount = count
            return
        }
        let predicate = #Predicate<TrainingSession> { $0.date >= weekStart && $0.date < weekEnd }
        weekSessions = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []
        lastImportedCount = count
        isImporting = false
    }

    // MARK: - Volumen semanal
    // Estimación de km desde duración y ritmo Z2 del perfil

    private func estimatedKm(_ template: SessionTemplate) -> Double {
        guard let duration = template.durationMin, template.type != .strength, template.type != .rest else { return 0 }
        return Double(duration) * 60.0 / profile.initialPaceZ2
    }

    var plannedKm: Double {
        templates.reduce(0) { $0 + estimatedKm($1) }
    }

    var completedKm: Double {
        templates.filter { isCompleted($0) }.reduce(0.0) { sum, t in
            // Priorizar distancia real de HealthKit si existe
            if let session = storedSession(for: t), let dist = session.distance {
                return sum + dist
            }
            return sum + estimatedKm(t)
        }
    }

    var progress: Double {
        plannedKm > 0 ? min(1.0, completedKm / plannedKm) : 0
    }

    // MARK: - Resumen semanal

    var strengthSessionCount: Int {
        templates.filter { !$0.exercises.isEmpty }.count
    }

    var qualitySessionCount: Int {
        templates.filter { $0.type == .tempo || $0.type == .intervals }.count
    }

    func zoneRangeText(for zone: Zone) -> String? {
        guard let threshold = profile.thresholdHR, let max = profile.maxHR else { return nil }
        return FrielZoneCalculator.rangeText(for: zone, thresholdHR: threshold, maxHR: max)
    }

    // MARK: - Calendario

    /// Inicio de la semana actual respetando la preferencia del usuario (UserDefaults "weekStartDay")
    static func mondayOfCurrentWeek(from date: Date = .now) -> Date {
        let saved = UserDefaults.standard.integer(forKey: "weekStartDay")
        var calendar = Calendar.current
        calendar.firstWeekday = saved > 0 ? saved : 2  // 2 = lunes por defecto
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return calendar.startOfDay(for: start)
    }

    /// Índice de día con lunes = 0
    static func dayIndex(of date: Date) -> Int {
        (Calendar.current.component(.weekday, from: date) + 5) % 7
    }
}
