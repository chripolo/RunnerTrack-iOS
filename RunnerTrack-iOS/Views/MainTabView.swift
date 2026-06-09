import SwiftUI

struct MainTabView: View {
    let profile: UserProfile

    var body: some View {
        TabView {
            DashboardView(profile: profile)
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            PlanPlaceholderView()
                .tabItem { Label("Plan", systemImage: "calendar") }

            MetricsPlaceholderView()
                .tabItem { Label("Métricas", systemImage: "chart.xyaxis.line") }
        }
    }
}

// MARK: - Placeholders

// TODO: S4 — vista Plan Semanal completa con 7 días y registro de sesión
struct PlanPlaceholderView: View {
    var body: some View {
        placeholderContent(icon: "calendar", title: "Semana S01", subtitle: "Próximamente")
    }
}

// TODO: S6 — vista Métricas con gráfico de ritmo Z2 y volumen semanal
struct MetricsPlaceholderView: View {
    var body: some View {
        placeholderContent(icon: "chart.xyaxis.line", title: "Métricas", subtitle: "Próximamente")
    }
}

private func placeholderContent(icon: String, title: String, subtitle: String) -> some View {
    VStack(spacing: 16) {
        Image(systemName: icon)
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(DS.Colors.accent.opacity(0.6))
        Text(title)
            .font(DS.Typo.screenTitle)
            .foregroundStyle(DS.Colors.textPrimary)
        Text(subtitle.uppercased())
            .font(DS.Typo.label)
            .tracking(1.5)
            .foregroundStyle(DS.Colors.textSecondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DS.Colors.background)
}
