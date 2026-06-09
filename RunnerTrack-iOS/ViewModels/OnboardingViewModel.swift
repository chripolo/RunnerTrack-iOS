import Foundation
import SwiftData

@Observable
final class OnboardingViewModel {
    var name: String = ""
    var age: String = ""
    var weight: String = ""
    var targetRace: RaceType = .marathon
    var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    var weeklyAvailableDays: Int = 4
    var hasGymAccess: Bool = false

    var currentStep: OnboardingStep = .welcome

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case personalData
        case raceGoal
        case availability
        case summary
    }

    var isCurrentStepValid: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .personalData:
            let nameOk = !name.trimmingCharacters(in: .whitespaces).isEmpty
            let ageOk = age.isEmpty || Int(age) != nil
            let weightOk = weight.isEmpty || Double(weight) != nil
            return nameOk && ageOk && weightOk
        case .raceGoal:
            return targetDate > .now
        case .availability:
            return weeklyAvailableDays >= 3
        case .summary:
            return true
        }
    }

    func advance() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    func back() {
        guard let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prev
    }

    func saveProfile(in context: ModelContext) {
        let ageInt = Int(age) ?? 30
        let weightDouble = Double(weight) ?? 70.0

        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            age: ageInt,
            weight: weightDouble,
            targetRace: targetRace,
            targetDate: targetDate,
            weeklyAvailableDays: weeklyAvailableDays,
            hasGymAccess: hasGymAccess
        )
        context.insert(profile)
        try? context.save()
    }
}
