import Foundation
import SwiftData

@Observable
final class ProfileViewModel {
    private let profile: UserProfile

    // Campos editables — se vuelcan al modelo solo al guardar
    var name: String
    var ageText: String
    var weightText: String
    var targetRace: RaceType
    var targetDate: Date
    var maxHRText: String
    var thresholdHRText: String
    var weeklyAvailableDays: Int

    init(profile: UserProfile) {
        self.profile = profile
        self.name = profile.name
        self.ageText = String(profile.age)
        self.weightText = String(format: "%.1f", profile.weight)
        self.targetRace = profile.targetRace
        self.targetDate = profile.targetDate
        self.maxHRText = profile.maxHR.map(String.init) ?? ""
        self.thresholdHRText = profile.thresholdHR.map(String.init) ?? ""
        self.weeklyAvailableDays = profile.weeklyAvailableDays
    }

    // Zonas en tiempo real desde los campos editados — antes de guardar
    var previewZones: [ZoneDisplay] {
        guard let threshold = Int(thresholdHRText), threshold > 100,
              let max = Int(maxHRText), max > 100 else { return [] }
        return FrielZoneCalculator.zones(thresholdHR: threshold, maxHR: max)
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && Int(ageText) != nil
            && Double(weightText) != nil
            && Int(maxHRText) != nil
            && Int(thresholdHRText) != nil
    }

    func save(in context: ModelContext) {
        guard let age = Int(ageText),
              let weight = Double(weightText),
              let maxHR = Int(maxHRText),
              let thresholdHR = Int(thresholdHRText) else { return }

        profile.name = name.trimmingCharacters(in: .whitespaces)
        profile.age = age
        profile.weight = weight
        profile.targetRace = targetRace
        profile.targetDate = targetDate
        profile.weeklyAvailableDays = weeklyAvailableDays
        profile.updateHeartRateData(maxHR: maxHR, thresholdHR: thresholdHR)
        try? context.save()
    }
}
