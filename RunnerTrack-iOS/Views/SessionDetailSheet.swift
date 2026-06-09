import SwiftUI

/// Detalle de una sesión planificada — sheet desde Dashboard o Plan.
/// Si `onToggleComplete` es nil, el botón de completar no se muestra.
struct SessionDetailSheet: View {
    let template: SessionTemplate
    let zoneRangeText: String?
    var isCompleted: Bool = false
    var onToggleComplete: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                badges
                Text(template.detail)
                    .font(DS.Typo.body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineSpacing(4)

                if !template.exercises.isEmpty {
                    exercisesSection
                }

                if let url = template.videoURL {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Ver vídeo de referencia", systemImage: "play.rectangle.fill")
                            .font(DS.Typo.rowTitle)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(DS.Colors.accent)
                }

                if onToggleComplete != nil {
                    completeButton
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(DS.Colors.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Cabecera

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.day.uppercased())
                .font(DS.Typo.label)
                .tracking(1.5)
                .foregroundStyle(DS.Colors.textSecondary)
            Text(template.title)
                .font(DS.Typo.screenTitle)
                .foregroundStyle(DS.Colors.textPrimary)
            Text(template.type.rawValue)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
        }
    }

    // MARK: - Zona y duración

    private var badges: some View {
        HStack(spacing: 12) {
            if let zone = template.zone {
                HStack(spacing: 8) {
                    Circle()
                        .fill(DS.Colors.zone(zone))
                        .frame(width: 10, height: 10)
                    Text("Zona \(zone.rawValue)")
                        .font(DS.Typo.metricSmall)
                        .foregroundStyle(DS.Colors.textPrimary)
                    if let range = zoneRangeText {
                        Text(range)
                            .font(DS.Typo.metricSmall)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(DS.Colors.surfaceElevated, in: Capsule())
            }
            if let duration = template.durationMin {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.Colors.accent)
                    Text("\(duration) min")
                        .font(DS.Typo.metricSmall)
                        .foregroundStyle(DS.Colors.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(DS.Colors.surfaceElevated, in: Capsule())
            }
        }
    }

    // MARK: - Ejercicios de fuerza

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Ejercicios")
            VStack(spacing: 0) {
                ForEach(template.exercises) { exercise in
                    HStack(spacing: 12) {
                        Image(systemName: exercise.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DS.Colors.accent)
                            .frame(width: 36, height: 36)
                            .background(DS.Colors.surfaceElevated, in: RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(DS.Typo.rowTitle)
                                .foregroundStyle(DS.Colors.textPrimary)
                            if let load = exercise.load {
                                Text(load)
                                    .font(DS.Typo.body)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }

                        Spacer()

                        Text(exercise.setsReps)
                            .font(DS.Typo.metricSmall)
                            .foregroundStyle(DS.Colors.accent)
                    }
                    .padding(.vertical, 8)

                    if exercise.id != template.exercises.last?.id {
                        Divider().overlay(DS.Colors.divider)
                    }
                }
            }
            .padding(.horizontal, DS.Layout.cardPadding)
            .padding(.vertical, 8)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        }
    }

    // MARK: - Botón completar

    private var completeButton: some View {
        Button {
            onToggleComplete?()
            dismiss()
        } label: {
            Label(
                isCompleted ? "Completada" : "Marcar completada",
                systemImage: isCompleted ? "checkmark.circle.fill" : "circle"
            )
            .font(DS.Typo.rowTitle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(isCompleted ? DS.Colors.surfaceElevated : DS.Colors.accent)
        .foregroundStyle(isCompleted ? DS.Colors.accent : .black)
    }
}
