import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            OnboardingContainerView()
        } else {
            DashboardPlaceholderView(profile: profiles[0])
        }
    }
}
