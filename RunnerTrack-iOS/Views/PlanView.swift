import SwiftUI
import SwiftData

struct PlanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm: PlanViewModel
    @State private var selectedSession: SessionTemplate?

    init(profile: UserProfile, healthService: HealthDataService) {
        _vm = State(initialValue: PlanViewModel(profile: profile, healthService: healthService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Layout.sectionSpacing) {
                header
                progressCard
                sessionList
                weekSummary
            }
            .padding(.horizontal, DS.Layout.screenPadding)
            .padding(.bottom, 32)
        }
        .background(DS.Colors.background)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await vm.importFromHealthKit(context: modelContext) }
                } label: {
                    if vm.isImporting {
                        ProgressView().tint(DS.Colors.accent)
                    } else {
                        Label("Sync Apple Health", systemImage: "arrow.triangle.2.circlepath")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(DS.Colors.accent)
                    }
                }
                .disabled(vm.isImporting)
            }
        }
        .onAppear { vm.ensureWeekSessions(context: modelContext) }
        .sheet(item: $selectedSession) { template in
            SessionDetailSheet(
                template: template,
                zoneRangeText: template.zone.flatMap { vm.zoneRangeText(for: $0) },
                isCompleted: vm.isCompleted(template),
                onToggleComplete: { vm.toggleCompleted(template, context: modelContext) },
                session: vm.storedSession(for: template)
            )
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Semana S01 · Bloque A")
                .font(DS.Typo.screenTitle)
                .foregroundStyle(DS.Colors.textPrimary)

            HStack(spacing: 8) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                Text("CARGA 1/3")
                    .font(DS.Typo.label)
                    .tracking(1.5)
            }
            .foregroundStyle(DS.Colors.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(DS.Colors.accent.opacity(0.12), in: Capsule())
        }
        .padding(.top, 16)
    }

    // MARK: - Progreso de volumen

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VOLUMEN SEMANAL")
                    .font(DS.Typo.label)
                    .tracking(1.5)
                    .foregroundStyle(DS.Colors.textSecondary)
                Spacer()
                Text("\(vm.completedKm, format: .number.precision(.fractionLength(1))) / \(vm.plannedKm, format: .number.precision(.fractionLength(1))) km")
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DS.Colors.surfaceElevated)
                    Capsule()
                        .fill(DS.Colors.accent)
                        .frame(width: geo.size.width * vm.progress)
                }
            }
            .frame(height: 8)
        }
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }

    // MARK: - Lista de sesiones

    private var sessionList: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Sesiones")
            VStack(spacing: 0) {
                ForEach(vm.templates) { template in
                    Button {
                        selectedSession = template
                    } label: {
                        SessionRow(template: template, isCompleted: vm.isCompleted(template))
                    }
                    .buttonStyle(.plain)

                    if template.id != vm.templates.last?.id {
                        Divider().overlay(DS.Colors.divider)
                    }
                }
            }
            .padding(.horizontal, DS.Layout.cardPadding)
            .padding(.vertical, 8)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        }
    }

    // MARK: - Resumen semanal

    private var weekSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Resumen")
            // Fila superior: volumen ocupa más espacio
            HStack(spacing: 12) {
                MetricCard(
                    icon: "figure.run",
                    label: "Planificado",
                    value: vm.plannedKm.formatted(.number.precision(.fractionLength(1))),
                    unit: "km"
                )
                .frame(maxWidth: .infinity)
                VStack(spacing: 12) {
                    MetricCard(icon: "dumbbell.fill", label: "Fuerza", value: "\(vm.strengthSessionCount)", unit: "ses.")
                    MetricCard(icon: "bolt.fill", label: "Calidad", value: "\(vm.qualitySessionCount)", unit: "ses.")
                }
                .frame(maxWidth: 120)
            }
        }
    }
}
