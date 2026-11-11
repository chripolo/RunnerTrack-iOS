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
            Section("Perfil") {
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
                LabeledContent("Inicio semana", value: vm.weekStartDay == 2 ? "Lunes" : "Domingo")
            }

            Section("Apple Health") {
                LabeledContent("Conexión") {
                    Text(vm.healthPermissionsGranted ? "Autorizado" : "Sin acceso")
                        .foregroundStyle(vm.healthPermissionsGranted ? .green : DS.Colors.textSecondary)
                }
                if vm.healthPermissionsGranted {
                    LabeledContent("Historial a importar") {
                        if vm.fetchedWorkouts.isEmpty {
                            Text("Sin entrenos previos")
                                .foregroundStyle(DS.Colors.textSecondary)
                        } else if vm.wantsToImport {
                            Text("\(vm.fetchedWorkouts.count) entrenos")
                                .foregroundStyle(DS.Colors.accent)
                        } else {
                            Text("No importar")
                                .foregroundStyle(DS.Colors.textSecondary)
                        }
                    }
                }
            }

            Section {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DS.Colors.accent)
                    Text("Todo listo. Vamos a construir tu plan.")
                        .foregroundStyle(DS.Colors.textSecondary)
                        .font(.callout)
                }
            }
        }
    }
}
