import SwiftUI
import SwiftData

@main
struct RunnerTrackApp: App {
    // Inyección del servicio de salud — Mock en DEBUG, HealthKit real en RELEASE
    #if DEBUG
    private let healthService: HealthDataService = MockHealthDataService()
    #else
    private let healthService: HealthDataService = RealHealthDataService()
    #endif

    var body: some Scene {
        WindowGroup {
            RootView(healthService: healthService)
        }
        .modelContainer(for: [UserProfile.self, TrainingSession.self, WeeklyPlan.self, DailyMetric.self])
    }
}
