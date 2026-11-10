import SwiftUI

struct OnboardingAvailabilityView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        Form {
            Section("Días disponibles para entrenar") {
                Picker("Días/semana", selection: $vm.weeklyAvailableDays) {
                    ForEach(3...5, id: \.self) { days in
                        Text("\(days) días").tag(days)
                    }
                }
                .pickerStyle(.segmented)

                Text("Mínimo 3 para un plan efectivo.")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            Section("Instalaciones") {
                Toggle("Tengo acceso a gimnasio", isOn: $vm.hasGymAccess)
            }
        }
    }
}
