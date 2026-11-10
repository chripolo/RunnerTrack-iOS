import SwiftUI
import Charts

struct MetricsView: View {
    @State private var vm: MetricsViewModel

    init(healthService: HealthDataService) {
        _vm = State(initialValue: MetricsViewModel(healthService: healthService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Layout.sectionSpacing) {
                title
                todaySection
                paceChartSection
                restingHRSection
                statsSection
            }
            .padding(.horizontal, DS.Layout.screenPadding)
            .padding(.bottom, 32)
        }
        .background(DS.Colors.background)
        .task { await vm.loadHealthData() }
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
            // Eje invertido: menor seg/km = más rápido = arriba.
            // Dominio explícito con margen para que la línea de objetivo no quede pegada al borde.
            .chartYScale(domain: [470, 355])
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

    // MARK: - FC reposo última semana

    private var restingHRSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "FC reposo · última semana")
            Chart {
                ForEach(vm.restingHRWeek) { point in
                    // yStart en la base del dominio — sin esto la barra nace en 0 y desborda la tarjeta
                    BarMark(
                        x: .value("Día", point.day),
                        yStart: .value("Base", 40),
                        yEnd: .value("FC", point.bpm)
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
            .chartYScale(domain: 40...56)
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

    // MARK: - Estadísticas acumuladas

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Acumulado · 12 semanas")
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
}
