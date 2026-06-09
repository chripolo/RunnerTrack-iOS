import Foundation
import SwiftData

@Model
final class WeeklyPlan {
    var weekNumber: Int                 // S01, S02... relativo al inicio del bloque
    var blockName: String               // "A", "B", "C", "D"
    var cycleWeek: Int                  // 1, 2, 3 = carga / 4 = descarga
    var targetVolumeKm: Double
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var sessions: [TrainingSession]

    init(weekNumber: Int, blockName: String, cycleWeek: Int, targetVolumeKm: Double, notes: String? = nil) {
        self.weekNumber = weekNumber
        self.blockName = blockName
        self.cycleWeek = cycleWeek
        self.targetVolumeKm = targetVolumeKm
        self.notes = notes
        self.sessions = []
    }
}
