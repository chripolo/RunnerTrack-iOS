import SwiftUI
import SwiftData

/// Perfil del corredor — se presenta como sheet desde el Dashboard
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ProfileViewModel

    init(profile: UserProfile) {
        _vm = State(initialValue: ProfileViewModel(profile: profile))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos personales") {
                    TextField("Nombre", text: $vm.name)
                    LabeledContent("Edad") {
                        TextField("43", text: $vm.ageText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    LabeledContent("Peso (kg)") {
                        TextField("83.0", text: $vm.weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Objetivo") {
                    Picker("Carrera", selection: $vm.targetRace) {
                        ForEach(RaceType.allCases, id: \.self) { race in
                            Text(race.rawValue).tag(race)
                        }
                    }
                    DatePicker("Fecha objetivo", selection: $vm.targetDate, in: Date.now..., displayedComponents: .date)
                }

                Section {
                    LabeledContent("FC máxima") {
                        TextField("178", text: $vm.maxHRText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    LabeledContent("FC umbral") {
                        TextField("172", text: $vm.thresholdHRText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                } header: {
                    Text("Fisiología")
                } footer: {
                    Text("Las zonas se recalculan automáticamente al cambiar la FC umbral.")
                }

                Section("Zonas Friel") {
                    if vm.previewZones.isEmpty {
                        Text("Introduce FC máxima y umbral válidas")
                            .font(DS.Typo.body)
                            .foregroundStyle(DS.Colors.textSecondary)
                    } else {
                        ForEach(vm.previewZones) { display in
                            ZoneRow(zone: display.zone, name: display.name, rangeText: display.rangeText)
                        }
                    }
                }

                Section("Disponibilidad") {
                    Stepper("\(vm.weeklyAvailableDays) días por semana", value: $vm.weeklyAvailableDays, in: 3...5)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DS.Colors.background)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        vm.save(in: modelContext)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!vm.canSave)
                }
            }
        }
    }
}
