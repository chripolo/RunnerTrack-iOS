import Foundation
import SwiftData

@Observable
final class OnboardingViewModel {
    var name: String = ""
    var age: String = ""
    var weight: String = ""
    var targetRace: RaceType = .marathon
    var goalTier: RaceGoalTier = .conservative
    var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    var weeklyAvailableDays: Int = 4
    var hasGymAccess: Bool = false

    // Preferencias (paso 4)
    var weekStartDay: Int = 2  // 2 = Lunes

    // HealthKit (paso 5)
    var healthPermissionsGranted: Bool = false
    var healthPermissionsRequested: Bool = false

    // Importar historial (paso 6)
    var fetchedWorkouts: [HealthWorkout] = []
    var wantsToImport: Bool = true
    var isFetchingWorkouts: Bool = false

    var currentStep: OnboardingStep = .welcome

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case personalData = 1
        case raceGoal = 2
        case availability = 3
        case preferences = 4
        case healthPermissions = 5
        case importHistory = 6
        case summary = 7
    }

    var isCurrentStepValid: Bool {
        switch currentStep {
        case .welcome:        return true
        case .personalData:
            let nameOk = !name.trimmingCharacters(in: .whitespaces).isEmpty
            let ageOk = age.isEmpty || Int(age) != nil
            let weightOk = weight.isEmpty || Double(weight) != nil
            return nameOk && ageOk && weightOk
        case .raceGoal:       return targetDate > .now
        case .availability:   return weeklyAvailableDays >= 3
        case .preferences:    return true
        case .healthPermissions: return healthPermissionsRequested
        case .importHistory:  return !isFetchingWorkouts
        case .summary:        return true
        }
    }

    func advance() {
        var nextRaw = currentStep.rawValue + 1
        // Si no se concedieron permisos, saltar importHistory
        if currentStep == .healthPermissions && !healthPermissionsGranted {
            nextRaw += 1
        }
        if let next = OnboardingStep(rawValue: nextRaw) {
            currentStep = next
        }
    }

    func back() {
        var prevRaw = currentStep.rawValue - 1
        // Al retroceder desde importHistory si no hay permisos, saltar healthPermissions
        if currentStep == .summary && !healthPermissionsGranted {
            prevRaw -= 1
        }
        if let prev = OnboardingStep(rawValue: prevRaw) {
            currentStep = prev
        }
    }

    func finishOnboarding(in context: ModelContext) {
        // Guardar preferencias en UserDefaults
        UserDefaults.standard.set(weekStartDay, forKey: "weekStartDay")

        // Guardar perfil
        let ageInt = Int(age) ?? 30
        let weightDouble = Double(weight) ?? 70.0
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            age: ageInt,
            weight: weightDouble,
            targetRace: targetRace,
            goalTier: goalTier,
            targetDate: targetDate,
            weeklyAvailableDays: weeklyAvailableDays,
            hasGymAccess: hasGymAccess
        )
        context.insert(profile)

        // Importar historial si el usuario lo eligió
        if wantsToImport && !fetchedWorkouts.isEmpty {
            WorkoutImporter.importUnmatched(fetchedWorkouts, into: context)
        }

        try? context.save()
    }
}
