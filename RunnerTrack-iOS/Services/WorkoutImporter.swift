import Foundation
import SwiftData

/// Convierte [HealthWorkout] de HealthKit en TrainingSession en SwiftData.
/// Solo inserta sesiones en días que aún no tienen ninguna registrada.
struct WorkoutImporter {

    /// Devuelve el número de sesiones insertadas
    static func importWorkouts(_ workouts: [HealthWorkout], into context: ModelContext) -> Int {
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
            session.distance = workout.distanceKm
            session.avgHR = workout.avgHR
            session.completed = true
            context.insert(session)
            inserted += 1
        }
        if inserted > 0 { try? context.save() }
        return inserted
    }

    private static func sessionType(for workout: HealthWorkout) -> SessionType {
        workout.durationMinutes >= 70 ? .longRun : .easyRun
    }

    /// Estimación de zona basada en FC media — valores aproximados para umbral 170–175 bpm
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
