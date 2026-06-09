import SwiftUI

struct OnboardingRaceGoalView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        Form {
            Section("Objetivo de carrera") {
                Picker("Distancia", selection: $vm.targetRace) {
                    ForEach(RaceType.allCases, id: \.self) { race in
                        Text(race.rawValue).tag(race)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section("Fecha objetivo") {
                DatePicker(
                    "Fecha de carrera",
                    selection: $vm.targetDate,
                    in: Date.now...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
        }
    }
}
