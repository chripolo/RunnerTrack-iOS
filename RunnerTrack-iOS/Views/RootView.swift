import SwiftUI
import SwiftData

struct RootView: View {
    let healthService: HealthDataService

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showSplash = true

    var body: some View {
        ZStack {
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

            if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}
