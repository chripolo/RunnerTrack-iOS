import SwiftUI
import SwiftData
import Charts

struct MetricsView: View {
    @State private var vm: MetricsViewModel
    @Query private var allSessions: [TrainingSession]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    init(healthService: HealthDataService) {
        _vm = State(initialValue: MetricsViewModel(healthService: healthService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Layout.sectionSpacing) {
                title
                todaySection
                paceChartSection
                weeklyVolumeSection
                restingHRSection
                statsSection
            }
            .padding(.horizontal, DS.Layout.screenPadding)
            .padding(.bottom, 32)
        }
        .background(DS.Colors.background)
        .task {
            await vm.loadHealthData()
            vm.updateWithSessions(allSessions, profile: profile)
        }
        .onChange(of: allSessions) { _, sessions in
            vm.updateWithSessions(sessions, profile: profile)
        }
        .onChange(of: profiles) { _, _ in
            vm.updateWithSessions(allSessions, profile: profile)
        }
    }

    private var title: some View {
        Text("Métricas")
            .font(DS.Typo.screenTitle)
            .foregroundStyle(DS.Colors.textPrimary)
            .padding(.top, 16)
    }

    // MARK: - Hoy

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Hoy")
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
            alertStateCard
        }
    }

    private var alertStateCard: some View {
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

    // MARK: - Progresión ritmo Z2

    private var paceChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Progresión ritmo Z2")
            if vm.paceHistory.isEmpty {
                emptyChartPlaceholder(message: "Importa tus entrenos para ver la progresión")
            } else {
                Chart {
                    ForEach(vm.paceHistory) { point in
                        LineMark(
                            x: .value("Fecha", point.date),
                            y: .value("Ritmo", point.secPerKm)
                        )
                        .foregroundStyle(DS.Colors.zone(.z2))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Fecha", point.date),
                            y: .value("Ritmo", point.secPerKm)
                        )
                        .foregroundStyle(DS.Colors.zone(.z2))
                        .symbolSize(40)
                    }

                    RuleMark(y: .value("Objetivo", vm.targetPace))
                        .foregroundStyle(DS.Colors.accent)
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                        .annotation(position: .bottom, alignment: .trailing) {
                            Text("Objetivo \(MetricsViewModel.paceString(vm.targetPace))")
                                .font(DS.Typo.label)
                                .foregroundStyle(DS.Colors.accent)
                        }
                }
                .chartYScale(domain: [vm.paceDomainMax, vm.paceDomainMin])
                .chartPlotStyle { $0.clipped() }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(DS.Colors.divider)
                        AxisValueLabel {
                            if let pace = value.as(Double.self) {
                                Text(MetricsViewModel.paceString(pace))
                                    .font(DS.Typo.label)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine().foregroundStyle(DS.Colors.divider)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).locale(Locale(identifier: "es_ES")))
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .frame(height: 220)
                .padding(DS.Layout.cardPadding)
                .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
            }
        }
    }

    // MARK: - Volumen semanal

    private var weeklyVolumeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Volumen semanal · 12 semanas")
            if vm.weeklyVolume.isEmpty {
                emptyChartPlaceholder(message: "Sin entrenamientos registrados")
            } else {
                Chart {
                    ForEach(vm.weeklyVolume) { point in
                        BarMark(
                            x: .value("Semana", point.label),
                            y: .value("km", point.km)
                        )
                        .foregroundStyle(DS.Colors.accent.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(DS.Colors.divider)
                        AxisValueLabel().foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(DS.Typo.label)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .frame(height: 180)
                .padding(DS.Layout.cardPadding)
                .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
            }
        }
    }

    // MARK: - FC reposo última semana

    private var restingHRSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "FC reposo · última semana")
            if vm.restingHRWeek.isEmpty {
                emptyChartPlaceholder(message: "Sin datos de FC reposo")
            } else {
                let minBPM = Double((vm.restingHRWeek.map(\.bpm).min() ?? 40) - 4)
                let maxBPM = Double((vm.restingHRWeek.map(\.bpm).max() ?? 56) + 4)
                Chart {
                    ForEach(vm.restingHRWeek) { point in
                        BarMark(
                            x: .value("Día", point.day),
                            yStart: .value("Base", minBPM),
                            yEnd: .value("FC", Double(point.bpm))
                        )
                        .foregroundStyle(DS.Colors.zone(.z1))
                        .cornerRadius(4)
                    }

                    RuleMark(y: .value("Alerta", vm.restingAlertThreshold))
                        .foregroundStyle(DS.Colors.zone(.z5))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Alerta \(vm.restingAlertThreshold) bpm")
                                .font(DS.Typo.label)
                                .foregroundStyle(DS.Colors.zone(.z5))
                        }
                }
                .chartYScale(domain: minBPM...maxBPM)
                .chartPlotStyle { $0.clipped() }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(DS.Colors.divider)
                        AxisValueLabel().foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel().foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .frame(height: 180)
                .padding(DS.Layout.cardPadding)
                .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
            }
        }
    }

    // MARK: - Estadísticas acumuladas

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Acumulado · 90 días")
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MetricCard(icon: "point.topleft.down.curvedto.point.bottomright.up", label: "Distancia", value: vm.totalDistanceKm.formatted(.number.precision(.fractionLength(0))), unit: "km")
                    MetricCard(icon: "clock.fill", label: "Tiempo", value: vm.totalTimeText, unit: "")
                }
                HStack(spacing: 12) {
                    MetricCard(icon: "calendar", label: "Semanas", value: "\(vm.activeWeeks)", unit: "activas")
                    MetricCard(icon: "arrow.down.right", label: "Mejora Z2", value: vm.paceImprovementText, unit: vm.paceImprovementDetail)
                }
            }
        }
    }

    // MARK: - Placeholder

    private func emptyChartPlaceholder(message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 28))
                    .foregroundStyle(DS.Colors.textSecondary.opacity(0.4))
                Text(message)
                    .font(DS.Typo.body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(height: 100)
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }
}
