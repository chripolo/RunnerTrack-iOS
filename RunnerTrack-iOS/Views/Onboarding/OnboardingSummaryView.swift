import SwiftUI

struct OnboardingSummaryView: View {
    let vm: OnboardingViewModel

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "es_ES")
        return f
    }()

    var body: some View {
        List {
            Section("Resumen") {
                LabeledContent("Nombre", value: vm.name)
                LabeledContent("Edad", value: vm.age + " años")
                LabeledContent("Peso", value: vm.weight + " kg")
            }

            Section("Objetivo") {
                LabeledContent("Carrera", value: vm.targetRace.rawValue)
                LabeledContent("Fecha", value: Self.dateFormatter.string(from: vm.targetDate))
            }

            Section("Entrenamiento") {
                LabeledContent("Días/semana", value: "\(vm.weeklyAvailableDays)")
                LabeledContent("Gimnasio", value: vm.hasGymAccess ? "Sí" : "No")
            }

            Section {
                Text("Todo listo. Vamos a construir tu plan.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }
}
