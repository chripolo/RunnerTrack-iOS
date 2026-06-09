import SwiftUI

struct MainTabView: View {
    let profile: UserProfile

    var body: some View {
        TabView {
            DashboardView(profile: profile)
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            PlanView(profile: profile)
                .tabItem { Label("Plan", systemImage: "calendar") }

            MetricsView()
                .tabItem { Label("Métricas", systemImage: "chart.xyaxis.line") }
        }
    }
}
