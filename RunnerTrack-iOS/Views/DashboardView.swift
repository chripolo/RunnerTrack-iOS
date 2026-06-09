import SwiftUI

struct DashboardView: View {
    let profile: UserProfile
    @State private var vm: DashboardViewModel
    @State private var selectedSession: SessionTemplate?
    @State private var showProfile = false

    init(profile: UserProfile) {
        self.profile = profile
        _vm = State(initialValue: DashboardViewModel(profile: profile, healthService: HealthServiceFactory.make()))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Layout.sectionSpacing) {
                    header
                    raceCard
                    healthMetrics
                    alertCard
                    weekSection
                }
                .padding(.horizontal, DS.Layout.screenPadding)
                .padding(.bottom, 32)
            }
            .background(DS.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(DS.Colors.accent)
                    }
                }
            }
            .task { await vm.loadHealthData() }
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(
                    template: session,
                    zoneRangeText: session.zone.flatMap { vm.zoneRangeText(for: $0) }
                )
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(profile: profile)
            }
        }
    }

    // MARK: - Cabecera con saludo dinámico

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vm.greeting)
                .font(DS.Typo.subtitle)
                .foregroundStyle(DS.Colors.textSecondary)
            Text(vm.userName)
                .font(DS.Typo.screenTitle)
                .foregroundStyle(DS.Colors.textPrimary)
        }
    }

    // MARK: - Tarjeta de carrera objetivo

    private var raceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.Colors.accent)
                Text("OBJETIVO")
                    .font(DS.Typo.label)
                    .tracking(1.5)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            Text(vm.raceName)
                .font(DS.Typo.rowTitle)
                .foregroundStyle(DS.Colors.textPrimary)
            Text(vm.raceDateText)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(vm.daysUntilRace)")
                    .font(DS.Typo.metricLarge)
                    .foregroundStyle(DS.Colors.accent)
                Text("días")
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }

    // MARK: - Métricas de salud

    private var healthMetrics: some View {
        HStack(spacing: 12) {
            MetricCard(
                icon: "heart.fill",
                label: "FC Reposo",
                value: vm.restingHR.map(String.init) ?? "—",
                unit: "bpm"
            )
            MetricCard(
                icon: "waveform.path.ecg",
                label: "HRV",
                value: vm.hrv.map { String(format: "%.0f", $0) } ?? "—",
                unit: "ms"
            )
        }
    }

    // MARK: - Estado del motor de reglas

    private var alertCard: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(DS.Colors.alert(vm.alertLevel))
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.alertLevel.title)
                    .font(DS.Typo.rowTitle)
                    .foregroundStyle(DS.Colors.textPrimary)
                Text(vm.alertLevel.message)
                    .font(DS.Typo.body)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }

    // MARK: - Esta semana (plan S01)

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Esta semana · S01")
            VStack(spacing: 0) {
                ForEach(vm.weekSessions) { session in
                    Button {
                        selectedSession = session
                    } label: {
                        SessionRow(template: session)
                    }
                    .buttonStyle(.plain)
                    if session.id != vm.weekSessions.last?.id {
                        Divider().overlay(DS.Colors.divider)
                    }
                }
            }
            .padding(.horizontal, DS.Layout.cardPadding)
            .padding(.vertical, 8)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        }
    }
}
