import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var age: Int
    var weight: Double
    var targetRace: RaceType
    var targetDate: Date
    var initialPaceZ2: Double           // seg/km — resultado del test de onboarding
    var maxHR: Int?                     // manual o estimado: 220 - age
    var thresholdHR: Int?               // umbral Friel — manual u estimado: maxHR * 0.96
    var zone1Max: Int                   // calculado
    var zone2Max: Int
    var zone3Max: Int
    var zone4Max: Int
    var zone5Max: Int
    var weeklyAvailableDays: Int        // 3–5
    var hasGymAccess: Bool

    init(
        name: String,
        age: Int,
        weight: Double,
        targetRace: RaceType,
        targetDate: Date,
        initialPaceZ2: Double = 370,
        maxHR: Int? = nil,
        thresholdHR: Int? = nil,
        weeklyAvailableDays: Int = 4,
        hasGymAccess: Bool = false
    ) {
        self.name = name
        self.age = age
        self.weight = weight
        self.targetRace = targetRace
        self.targetDate = targetDate
        self.initialPaceZ2 = initialPaceZ2
        self.hasGymAccess = hasGymAccess
        self.weeklyAvailableDays = weeklyAvailableDays

        // Calcular maxHR y thresholdHR
        let resolvedMax = maxHR ?? (220 - age)
        let resolvedThreshold = thresholdHR ?? Int((Double(resolvedMax) * 0.96).rounded())
        self.maxHR = resolvedMax
        self.thresholdHR = resolvedThreshold

        // Zonas Friel — se inicializan en recalculateZones()
        self.zone1Max = 0
        self.zone2Max = 0
        self.zone3Max = 0
        self.zone4Max = 0
        self.zone5Max = 0
        recalculateZones()
    }

    /// Actualiza los datos cardíacos y recalcula zonas — usado por el seed y futuros ajustes manuales
    func updateHeartRateData(maxHR: Int, thresholdHR: Int) {
        self.maxHR = maxHR
        self.thresholdHR = thresholdHR
        recalculateZones()
    }

    /// Zonas Friel según CLAUDE.md §5 — redondeo, no truncado (172 × 0.94 = 161.68 → 162)
    private func recalculateZones() {
        guard let threshold = thresholdHR, let max = maxHR else { return }
        zone1Max = Int((Double(threshold) * 0.84).rounded())
        zone2Max = Int((Double(threshold) * 0.89).rounded())
        zone3Max = Int((Double(threshold) * 0.94).rounded())
        zone4Max = Int((Double(threshold) * 0.99).rounded())
        zone5Max = max
    }
}
