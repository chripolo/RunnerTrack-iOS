import SwiftUI
import SwiftData

struct RootView: View {
    let healthService: HealthDataService

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(profile: profile, healthService: healthService)
            } else {
                OnboardingContainerView(healthService: healthService)
            }
        }
        .preferredColorScheme(.dark)
        .tint(DS.Colors.accent)
        .onAppear {
            ProfileSeeder.seedIfNeeded(context: modelContext)
        }
    }
}
