import Foundation
import SwiftData

// MARK: - Resultado del matching

struct WorkoutConflict: Identifiable, Equatable {
    let id = UUID()
    let session: TrainingSession
    let candidates: [HealthWorkout]

    static func == (lhs: WorkoutConflict, rhs: WorkoutConflict) -> Bool { lhs.id == rhs.id }
}

struct WorkoutMatchResult {
    let conflicts: [WorkoutConflict]  // >1 workout por sesión planificada
    let unmatched: [HealthWorkout]    // sin sesión planificada ese día
}

// MARK: - WorkoutImporter

struct WorkoutImporter {

    // MARK: Matching (semana planificada ↔ HealthKit)

    /// Intenta emparejar workouts con sesiones planificadas no completadas.
    /// - matched 1:1: se aplica automáticamente y persiste
    /// - matched >1: devuelve conflicto para que el usuario decida
    /// - sin sesión planificada: devuelve como unmatched
    @discardableResult
    static func matchAndApply(
        _ workouts: [HealthWorkout],
        against sessions: [TrainingSession],
        context: ModelContext
    ) -> WorkoutMatchResult {
        let incomplete = sessions.filter { !$0.completed }
        let byDay = Dictionary(grouping: workouts) {
            Calendar.current.startOfDay(for: $0.date)
        }

        var conflicts: [WorkoutConflict] = []
        var usedWorkoutIDs: Set<UUID> = []

        for session in incomplete {
            let day = Calendar.current.startOfDay(for: session.date)
            let candidates = (byDay[day] ?? []).filter { $0.durationMinutes >= 5 }

            switch candidates.count {
            case 0:
                break
            case 1:
                applyWorkout(candidates[0], to: session)
                usedWorkoutIDs.insert(candidates[0].id)
            default:
                conflicts.append(WorkoutConflict(session: session, candidates: candidates))
                usedWorkoutIDs.formUnion(candidates.map(\.id))
            }
        }

        if !conflicts.isEmpty || sessions.contains(where: { !$0.completed }) {
            // aplica los 1:1; los conflictos se guardan cuando el usuario resuelva
        }
        try? context.save()

        // Workouts sin sesión planificada ese día
        let unmatched = workouts.filter { !usedWorkoutIDs.contains($0.id) }
        return WorkoutMatchResult(conflicts: conflicts, unmatched: unmatched)
    }

    /// Aplica un workout concreto a una sesión (llamado al resolver conflicto)
    static func applyWorkout(_ workout: HealthWorkout, to session: TrainingSession) {
        session.completed    = true
        session.actualDuration = workout.durationMinutes
        session.distance     = workout.distanceKm
        session.avgHR        = workout.avgHR
    }

    // MARK: Import sin sesión planificada (crea nuevas TrainingSession)

    /// Crea TrainingSession para workouts que no tienen sesión planificada ese día
    @discardableResult
    static func importUnmatched(_ workouts: [HealthWorkout], into context: ModelContext) -> Int {
        let existing = (try? context.fetch(FetchDescriptor<TrainingSession>())) ?? []
        let existingDays = Set(existing.map { Calendar.current.startOfDay(for: $0.date) })

        var inserted = 0
        for workout in workouts {
            let day = Calendar.current.startOfDay(for: workout.date)
            guard !existingDays.contains(day) else { continue }

            let session = TrainingSession(
                date: workout.date,
                type: sessionType(for: workout),
                plannedDuration: workout.durationMinutes,
                plannedZone: estimatedZone(avgHR: workout.avgHR)
            )
            session.actualDuration = workout.durationMinutes
            session.distance       = workout.distanceKm
            session.avgHR          = workout.avgHR
            session.completed      = true
            context.insert(session)
            inserted += 1
        }
        if inserted > 0 { try? context.save() }
        return inserted
    }

    private static func sessionType(for workout: HealthWorkout) -> SessionType {
        workout.durationMinutes >= 70 ? .longRun : .easyRun
    }

    private static func estimatedZone(avgHR: Int?) -> Zone {
        guard let hr = avgHR else { return .z2 }
        switch hr {
        case ..<145: return .z1
        case 145..<155: return .z2
        case 155..<163: return .z3
        case 163..<171: return .z4
        default:         return .z5
        }
    }
}
