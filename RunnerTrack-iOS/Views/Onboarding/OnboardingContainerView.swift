import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Barra de progreso
                ProgressView(value: Double(vm.currentStep.rawValue), total: Double(OnboardingViewModel.OnboardingStep.allCases.count - 1))
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Contenido del paso actual
                Group {
                    switch vm.currentStep {
                    case .welcome:
                        OnboardingWelcomeView()
                    case .personalData:
                        OnboardingPersonalDataView(vm: vm)
                    case .raceGoal:
                        OnboardingRaceGoalView(vm: vm)
                    case .availability:
                        OnboardingAvailabilityView(vm: vm)
                    case .summary:
                        OnboardingSummaryView(vm: vm)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

                // Botones de navegación
                HStack {
                    if vm.currentStep != .welcome {
                        Button("Atrás") { withAnimation { vm.back() } }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button(vm.currentStep == .summary ? "Empezar" : "Continuar") {
                        if vm.currentStep == .summary {
                            vm.saveProfile(in: modelContext)
                        } else {
                            withAnimation { vm.advance() }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!vm.isCurrentStepValid)
                }
                .padding()
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
