import Foundation
import SwiftData

@Model
final class TrainingSession {
    var date: Date
    var type: SessionType
    var plannedDuration: Int            // minutos
    var actualDuration: Int?            // nil = no completada
    var plannedZone: Zone
    var avgHR: Int?
    var maxHR: Int?
    var avgPace: Double?                // seg/km
    var distance: Double?               // km
    var feeling: Int?                   // RPE subjetivo 1–10
    var notes: String?
    var completed: Bool

    init(
        date: Date,
        type: SessionType,
        plannedDuration: Int,
        plannedZone: Zone,
        completed: Bool = false
    ) {
        self.date = date
        self.type = type
        self.plannedDuration = plannedDuration
        self.plannedZone = plannedZone
        self.completed = completed
    }
}
