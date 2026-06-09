import Foundation
import SwiftData

// Seed de desarrollo con los datos de ejemplo (CLAUDE.md §12).
// Solo actúa en DEBUG: corrige el perfil existente o lo crea si no hay ninguno.
// Para probar el onboarding desde cero: borrar la app del simulador.

enum ProfileSeeder {

    static func seedIfNeeded(context: ModelContext) {
        #if DEBUG
        let existing = (try? context.fetch(FetchDescriptor<UserProfile>())) ?? []

        if let profile = existing.first {
            correct(profile)
        } else {
            context.insert(makeDemoProfile())
        }
        try? context.save()
        #endif
    }

    /// Corrige el perfil existente con los datos cardíacos y fecha reales
    private static func correct(_ profile: UserProfile) {
        profile.updateHeartRateData(maxHR: 178, thresholdHR: 172)
        profile.targetDate = madridMarathonDate
        profile.targetRace = .marathon
        profile.initialPaceZ2 = 370
    }

    private static func makeDemoProfile() -> UserProfile {
        UserProfile(
            name: "Demo Runner",
            age: 35,
            weight: 75.0,
            targetRace: .marathon,
            targetDate: madridMarathonDate,
            initialPaceZ2: 370,
            maxHR: 178,
            thresholdHR: 172,
            weeklyAvailableDays: 5,
            hasGymAccess: false
        )
    }

    /// Maratón de Madrid — 27 abril 2027
    private static var madridMarathonDate: Date {
        var components = DateComponents()
        components.year = 2027
        components.month = 4
        components.day = 27
        return Calendar.current.date(from: components) ?? .now
    }
}
