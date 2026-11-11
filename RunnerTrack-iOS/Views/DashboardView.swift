import SwiftUI
import SwiftData

struct DashboardView: View {
    let profile: UserProfile
    @State private var vm: DashboardViewModel
    @State private var selectedSession: SessionTemplate?
    @State private var showProfile = false

    // Sesiones de la semana actual desde SwiftData para el progreso real
    @Query private var allSessions: [TrainingSession]

    init(profile: UserProfile, healthService: HealthDataService) {
        self.profile = profile
        _vm = State(initialValue: DashboardViewModel(profile: profile, healthService: healthService))
    }

    // MARK: - Helpers de progreso semanal

    private var weekSessions: [TrainingSession] {
        let start = PlanViewModel.mondayOfCurrentWeek()
        guard let end = Calendar.current.date(byAdding: .day, value: 7, to: start) else { return [] }
        return allSessions.filter { $0.date >= start && $0.date < end }
    }

    private var completedKm: Double { vm.completedKm(from: weekSessions) }
    private var completedCount: Int { vm.completedCount(from: weekSessions) }
    private var progress: Double {
        vm.plannedKm > 0 ? min(1.0, completedKm / vm.plannedKm) : 0
    }
    private var completedDayIndexes: Set<Int> {
        Set(weekSessions.filter(\.completed).map { PlanViewModel.dayIndex(of: $0.date) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Layout.sectionSpacing) {
                    header
                    raceCard
                    weekProgressCard
                    if let next = vm.nextTemplate(completedDayIndexes: completedDayIndexes) {
                        nextSessionCard(next)
                    }
                    healthMetrics
                    alertCard
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

    // MARK: - Progreso semanal

    private var weekProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: "Esta semana · S01")
                Spacer()
                Text("\(completedCount) de \(vm.plannedSessionCount) sesiones")
                    .font(DS.Typo.label)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            // Barra de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(DS.Colors.surfaceElevated)
                    Capsule()
                        .fill(DS.Colors.accent)
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 8)

            // Km completados vs planificados
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(completedKm, format: .number.precision(.fractionLength(1)))
                    .font(DS.Typo.metricMedium)
                    .foregroundStyle(DS.Colors.textPrimary)
                Text("/ \(vm.plannedKm, format: .number.precision(.fractionLength(1))) km")
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textSecondary)
                Spacer()
                // Puntos de los 7 días
                HStack(spacing: 5) {
                    ForEach(vm.weekSessions) { template in
                        Circle()
                            .fill(dayDotColor(for: template))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }

    private func dayDotColor(for template: SessionTemplate) -> Color {
        if template.type == .rest { return DS.Colors.surfaceElevated }
        if completedDayIndexes.contains(template.dayIndex) { return DS.Colors.accent }
        let todayIndex = (Calendar.current.component(.weekday, from: .now) + 5) % 7
        return template.dayIndex < todayIndex
            ? DS.Colors.textSecondary.opacity(0.3)   // pasado sin completar
            : DS.Colors.textSecondary.opacity(0.15)  // futuro
    }

    // MARK: - Próxima sesión

    private func nextSessionCard(_ template: SessionTemplate) -> some View {
        Button {
            selectedSession = template
        } label: {
            HStack(spacing: 14) {
                Capsule()
                    .fill(template.zone.map(DS.Colors.zone) ?? DS.Colors.accent)
                    .frame(width: 4, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text("PRÓXIMA SESIÓN · \(template.day.uppercased())")
                        .font(DS.Typo.label)
                        .tracking(1.0)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text(template.title)
                        .font(DS.Typo.rowTitle)
                        .foregroundStyle(DS.Colors.textPrimary)
                    if let zone = template.zone,
                       let rangeText = vm.zoneRangeText(for: zone) {
                        Text(rangeText)
                            .font(DS.Typo.body)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }

                Spacer()

                if let dur = template.durationMin {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(dur)")
                            .font(DS.Typo.metricMedium)
                            .foregroundStyle(DS.Colors.textPrimary)
                        Text("min")
                            .font(DS.Typo.label)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
            }
            .padding(DS.Layout.cardPadding)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        }
        .buttonStyle(.plain)
    }
}
