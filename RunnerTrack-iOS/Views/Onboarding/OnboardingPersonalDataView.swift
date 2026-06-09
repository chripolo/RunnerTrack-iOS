import SwiftUI

struct OnboardingPersonalDataView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        Form {
            Section("¿Cómo te llamas?") {
                TextField("Nombre", text: $vm.name)
                    .textContentType(.givenName)
            }

            Section("Datos físicos") {
                HStack {
                    Text("Edad")
                    Spacer()
                    TextField("43", text: $vm.age)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Peso (kg)")
                    Spacer()
                    TextField("83.0", text: $vm.weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
        }
    }
}
