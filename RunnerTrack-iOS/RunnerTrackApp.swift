import SwiftUI
import SwiftData

@main
struct RunnerTrackApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [UserProfile.self, TrainingSession.self, WeeklyPlan.self, DailyMetric.self])
    }
}
