import SwiftUI

// Placeholder hasta S3 — muestra zonas Friel calculadas del perfil
struct DashboardPlaceholderView: View {
    let profile: UserProfile

    var body: some View {
        NavigationStack {
            List {
                Section("Bienvenido") {
                    Text("Hola, \(profile.name) 👋")
                        .font(.title2.bold())
                }

                Section("Objetivo") {
                    LabeledContent("Carrera", value: profile.targetRace.rawValue)
                    LabeledContent("Fecha", value: profile.targetDate.formatted(date: .long, time: .omitted))
                }

                Section("Zonas Friel") {
                    zoneRow("Z1 Recuperación", range: "0 – \(profile.zone1Max) bpm")
                    zoneRow("Z2 Aeróbico", range: "\(profile.zone1Max + 1) – \(profile.zone2Max) bpm")
                    zoneRow("Z3 Tempo", range: "\(profile.zone2Max + 1) – \(profile.zone3Max) bpm")
                    zoneRow("Z4 Umbral", range: "\(profile.zone3Max + 1) – \(profile.zone4Max) bpm")
                    zoneRow("Z5 Máximo", range: "\(profile.zone4Max + 1) – \(profile.zone5Max) bpm")
                }
            }
            .navigationTitle("RunnerTrack")
        }
    }

    private func zoneRow(_ name: String, range: String) -> some View {
        LabeledContent(name, value: range)
    }
}
