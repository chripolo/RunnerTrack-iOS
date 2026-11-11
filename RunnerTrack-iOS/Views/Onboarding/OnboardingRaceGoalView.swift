import SwiftUI

struct OnboardingRaceGoalView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        Form {
            Section("Distancia") {
                Picker("Distancia", selection: $vm.targetRace) {
                    ForEach(RaceType.allCases, id: \.self) { race in
                        Text(race.rawValue).tag(race)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section {
                ForEach(RaceGoalTier.allCases, id: \.self) { tier in
                    Button {
                        vm.goalTier = tier
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tier.rawValue).font(DS.Typo.rowTitle)
                                Text(tier.finishTime(for: vm.targetRace))
                                    .font(DS.Typo.body)
                                    .foregroundStyle(DS.Colors.textSecondary)
                            }
                            Spacer()
                            if vm.goalTier == tier {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DS.Colors.accent)
                            }
                        }
                    }
                    .foregroundStyle(DS.Colors.textPrimary)
                }
            } header: {
                Text("Nivel de objetivo")
            } footer: {
                Text("Puedes cambiarlo desde tu perfil en cualquier momento.")
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
