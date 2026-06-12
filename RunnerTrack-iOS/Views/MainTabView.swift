import SwiftUI

struct MainTabView: View {
    let profile: UserProfile
    let healthService: HealthDataService

    var body: some View {
        TabView {
            DashboardView(profile: profile, healthService: healthService)
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            PlanView(profile: profile)
                .tabItem { Label("Plan", systemImage: "calendar") }

            MetricsView(healthService: healthService)
                .tabItem { Label("Métricas", systemImage: "chart.xyaxis.line") }
        }
    }
}
