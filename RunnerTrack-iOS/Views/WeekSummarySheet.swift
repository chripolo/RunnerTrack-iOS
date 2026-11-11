import SwiftUI

enum SummaryFilter: String, Identifiable {
    case volume   = "Volumen planificado"
    case strength = "Sesiones de fuerza"
    case quality  = "Sesiones de calidad"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .volume:   return "figure.run"
        case .strength: return "dumbbell.fill"
        case .quality:  return "bolt.fill"
        }
    }
}

/// Sheet con el desglose de sesiones que justifican una card del Resumen
struct WeekSummarySheet: View {
    let filter: SummaryFilter
    let templates: [SessionTemplate]
    let weekSessions: [TrainingSession]

    @Environment(\.dismiss) private var dismiss

    private var matchingTemplates: [SessionTemplate] {
        switch filter {
        case .volume:
            return templates.filter { $0.type != .rest }
        case .strength:
            return templates.filter { !$0.exercises.isEmpty }
        case .quality:
            return templates.filter { $0.type == .tempo || $0.type == .intervals }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(matchingTemplates) { template in
                        sessionRow(for: template)
                        if template.id != matchingTemplates.last?.id {
                            Divider().overlay(DS.Colors.divider).padding(.leading, 68)
                        }
                    }
                }
                .padding(.horizontal, DS.Layout.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(DS.Colors.background)
            .navigationTitle(filter.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(DS.Colors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func sessionRow(for template: SessionTemplate) -> some View {
        let stored = weekSessions.first { storedDayIndex($0) == template.dayIndex }
        let isCompleted = stored?.completed ?? false

        return HStack(spacing: 14) {
            // Indicador zona / completado
            ZStack {
                Circle()
                    .fill(isCompleted ? DS.Colors.accent : DS.Colors.surfaceElevated)
                    .frame(width: 40, height: 40)
                Image(systemName: isCompleted ? "checkmark" : filter.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isCompleted ? .black : DS.Colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(template.day)
                        .font(DS.Typo.label)
                        .tracking(0.8)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Spacer()
                    if isCompleted {
                        Text("COMPLETADA")
                            .font(DS.Typo.label)
                            .tracking(0.8)
                            .foregroundStyle(DS.Colors.accent)
                    }
                }
                Text(template.title)
                    .font(DS.Typo.rowTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                // Datos reales si existen, estimados si no
                HStack(spacing: 12) {
                    if let dist = stored?.distance {
                        Label(String(format: "%.1f km", dist), systemImage: "arrow.right")
                    } else if let dur = template.durationMin {
                        Label("\(dur) min", systemImage: "clock")
                    }
                    if let hr = stored?.avgHR {
                        Label("\(hr) bpm", systemImage: "heart")
                    }
                }
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func storedDayIndex(_ session: TrainingSession) -> Int {
        (Calendar.current.component(.weekday, from: session.date) + 5) % 7
    }
}
