import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    let healthService: HealthDataService

    @Environment(\.modelContext) private var modelContext
    @State private var vm = OnboardingViewModel()

    private var totalSteps: Double { Double(OnboardingViewModel.OnboardingStep.allCases.count - 1) }
    private var isLastStep: Bool { vm.currentStep == .summary }
    private var isFirstStep: Bool { vm.currentStep == .welcome }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(vm.currentStep.rawValue), total: totalSteps)
                    .padding(.horizontal)
                    .padding(.top, 8)

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
                    case .preferences:
                        OnboardingPreferencesView(vm: vm)
                    case .healthPermissions:
                        OnboardingHealthPermissionsView(vm: vm, healthService: healthService)
                    case .importHistory:
                        OnboardingImportHistoryView(vm: vm, healthService: healthService)
                    case .summary:
                        OnboardingSummaryView(vm: vm)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

                HStack {
                    if !isFirstStep {
                        Button("Atrás") { withAnimation { vm.back() } }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    Button(isLastStep ? "Empezar" : "Continuar") {
                        if isLastStep {
                            vm.finishOnboarding(in: modelContext)
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
