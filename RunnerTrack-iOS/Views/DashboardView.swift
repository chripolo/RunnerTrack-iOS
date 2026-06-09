import SwiftUI

struct DashboardView: View {
    @State private var vm: DashboardViewModel
    @State private var selectedSession: PlannedSessionPreview?

    init(profile: UserProfile) {
        _vm = State(initialValue: DashboardViewModel(profile: profile, healthService: HealthServiceFactory.make()))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Layout.sectionSpacing) {
                header
                raceCard
                healthMetrics
                zonesSection
                weekSection
            }
            .padding(.horizontal, DS.Layout.screenPadding)
            .padding(.bottom, 32)
        }
        .background(DS.Colors.background)
        .task { await vm.loadHealthData() }
        .sheet(item: $selectedSession) { session in
            SessionDetailSheet(session: session)
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
        .padding(.top, 16)
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

    // MARK: - Métricas de salud (mock en DEBUG)

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

    // MARK: - Zonas Friel

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Zonas Friel")
            VStack(spacing: 0) {
                ForEach(vm.zoneDisplays) { display in
                    ZoneRow(zone: display.zone, name: display.name, rangeText: display.rangeText)
                    if display.zone != .z5 {
                        Divider().overlay(DS.Colors.divider)
                    }
                }
            }
            .padding(.horizontal, DS.Layout.cardPadding)
            .padding(.vertical, 8)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        }
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
                        SessionRowView(session: session)
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

// MARK: - Fila de sesión semanal

private struct SessionRowView: View {
    let session: PlannedSessionPreview

    var body: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(session.zone.map(DS.Colors.zone) ?? DS.Colors.textSecondary.opacity(0.3))
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.day)
                    .font(DS.Typo.label)
                    .tracking(1.0)
                    .foregroundStyle(DS.Colors.textSecondary)
                Text(session.title)
                    .font(DS.Typo.rowTitle)
                    .foregroundStyle(DS.Colors.textPrimary)
            }

            Spacer()

            if let duration = session.durationMin {
                Text("\(duration)'")
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DS.Colors.textSecondary.opacity(0.5))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
