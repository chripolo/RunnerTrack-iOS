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
        let resolvedThreshold = thresholdHR ?? Int(Double(resolvedMax) * 0.96)
        self.maxHR = resolvedMax
        self.thresholdHR = resolvedThreshold

        // Zonas Friel
        self.zone1Max = Int(Double(resolvedThreshold) * 0.84)
        self.zone2Max = Int(Double(resolvedThreshold) * 0.89)
        self.zone3Max = Int(Double(resolvedThreshold) * 0.94)
        self.zone4Max = Int(Double(resolvedThreshold) * 0.99)
        self.zone5Max = resolvedMax
    }
}
