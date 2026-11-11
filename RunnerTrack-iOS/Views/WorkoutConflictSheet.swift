import SwiftUI

/// Sheet que aparece cuando hay varios workouts de HealthKit el mismo día que una sesión planificada.
/// El usuario elige cuál corresponde al plan o salta sin marcar completada.
struct WorkoutConflictSheet: View {
    let conflict: WorkoutConflict
    let onResolve: (HealthWorkout?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Contexto: sesión planificada
                VStack(alignment: .leading, spacing: 6) {
                    Text("SESIÓN PLANIFICADA")
                        .font(DS.Typo.label)
                        .tracking(1.0)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text(conflict.session.type.rawValue)
                        .font(DS.Typo.rowTitle)
                        .foregroundStyle(DS.Colors.textPrimary)
                    Text(conflict.session.date, format: .dateTime.weekday(.wide).day().month().locale(Locale(identifier: "es_ES")))
                        .font(DS.Typo.body)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                .padding(DS.Layout.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
                .padding(.horizontal, DS.Layout.screenPadding)
                .padding(.top, 16)

                // Candidatos
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Entrenos de este día")
                        .padding(.horizontal, DS.Layout.screenPadding)
                        .padding(.top, DS.Layout.sectionSpacing)

                    ForEach(conflict.candidates) { workout in
                        Button {
                            onResolve(workout)
                            dismiss()
                        } label: {
                            workoutRow(workout)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                // Saltar
                Button {
                    onResolve(nil)
                    dismiss()
                } label: {
                    Text("No corresponde a ninguno — saltar")
                        .font(DS.Typo.body)
                        .foregroundStyle(DS.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .padding(.horizontal, DS.Layout.screenPadding)
                .padding(.bottom, 24)
            }
            .background(DS.Colors.background)
            .navigationTitle("Varios entrenos encontrados")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func workoutRow(_ workout: HealthWorkout) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "figure.run")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(DS.Colors.accent)
                .frame(width: 40, height: 40)
                .background(DS.Colors.surfaceElevated, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.date, format: .dateTime.hour().minute().locale(Locale(identifier: "es_ES")))
                    .font(DS.Typo.rowTitle)
                    .foregroundStyle(DS.Colors.textPrimary)
                HStack(spacing: 12) {
                    Label("\(workout.durationMinutes) min", systemImage: "clock")
                    if let km = workout.distanceKm {
                        Label(String(format: "%.1f km", km), systemImage: "arrow.right")
                    }
                    if let hr = workout.avgHR {
                        Label("\(hr) bpm", systemImage: "heart")
                    }
                }
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 20))
                .foregroundStyle(DS.Colors.accent.opacity(0.6))
        }
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
        .padding(.horizontal, DS.Layout.screenPadding)
    }
}
