import SwiftUI

struct OnboardingImportHistoryView: View {
    @Bindable var vm: OnboardingViewModel
    let healthService: HealthDataService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Importar historial")
                        .font(.largeTitle.bold())
                    Text("Importa tus carreras anteriores para ver tu progresión desde el primer día.")
                        .font(.body)
                        .foregroundStyle(DS.Colors.textSecondary)
                }

                if vm.isFetchingWorkouts {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Buscando entrenos en Apple Health…")
                            .font(DS.Typo.body)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                    .padding(DS.Layout.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))

                } else if vm.fetchedWorkouts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(DS.Colors.textSecondary.opacity(0.4))
                        Text("No se encontraron carreras en los últimos 90 días")
                            .font(DS.Typo.body)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DS.Layout.cardPadding)
                    .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))

                } else {
                    // Resumen de entrenos encontrados
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(DS.Colors.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(vm.fetchedWorkouts.count) entrenos encontrados")
                                    .font(DS.Typo.rowTitle)
                                Text(workoutsSummary)
                                    .font(DS.Typo.body)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }

                        Divider()

                        Toggle(isOn: $vm.wantsToImport) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Importar al arrancar")
                                    .font(DS.Typo.rowTitle)
                                Text("Se crearán sesiones con distancia y ritmo real")
                                    .font(DS.Typo.body)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(DS.Layout.cardPadding)
                    .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))

                    if vm.wantsToImport {
                        // Preview de los últimos 5 entrenos
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vista previa")
                                .font(DS.Typo.label)
                                .foregroundStyle(DS.Colors.textSecondary)
                                .padding(.horizontal, 4)

                            ForEach(Array(vm.fetchedWorkouts.prefix(5))) { workout in
                                workoutRow(workout)
                            }

                            if vm.fetchedWorkouts.count > 5 {
                                Text("+ \(vm.fetchedWorkouts.count - 5) más…")
                                    .font(DS.Typo.body)
                                    .foregroundStyle(DS.Colors.textSecondary)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DS.Layout.screenPadding)
            .padding(.vertical, 24)
        }
        .task {
            vm.isFetchingWorkouts = true
            vm.fetchedWorkouts = await healthService.getRecentWorkouts(limit: 200)
            vm.isFetchingWorkouts = false
        }
    }

    private var workoutsSummary: String {
        let totalKm = vm.fetchedWorkouts.compactMap(\.distanceKm).reduce(0, +)
        let months = 3
        return String(format: "%.0f km · últimos %d meses", totalKm, months)
    }

    private func workoutRow(_ workout: HealthWorkout) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.date.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "es_ES"))))
                    .font(DS.Typo.rowTitle)
                HStack(spacing: 8) {
                    if let km = workout.distanceKm {
                        Text(String(format: "%.1f km", km))
                    }
                    if let hr = workout.avgHR {
                        Text("· \(hr) bpm")
                    }
                }
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
            }
            Spacer()
            Text("\(workout.durationMinutes) min")
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
        }
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }
}
