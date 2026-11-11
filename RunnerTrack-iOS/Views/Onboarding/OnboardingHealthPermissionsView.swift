import SwiftUI

struct OnboardingHealthPermissionsView: View {
    @Bindable var vm: OnboardingViewModel
    let healthService: HealthDataService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Conectar Apple Health")
                        .font(.largeTitle.bold())
                    Text("RunnerTrack lee tus datos de salud para adaptar el plan automáticamente. Nada se escribe — solo lectura.")
                        .font(.body)
                        .foregroundStyle(DS.Colors.textSecondary)
                }

                VStack(spacing: 12) {
                    permissionCard(
                        icon: "heart.fill",
                        color: DS.Colors.zone(.z5),
                        title: "FC Reposo",
                        description: "Detecta acumulación de fatiga cuando tu FC reposo sube 5+ bpm durante 3 días seguidos."
                    )
                    permissionCard(
                        icon: "waveform.path.ecg",
                        color: DS.Colors.zone(.z2),
                        title: "HRV",
                        description: "La variabilidad cardíaca es el mejor indicador de recuperación real. Alerta si baja de 50 ms."
                    )
                    permissionCard(
                        icon: "figure.run",
                        color: DS.Colors.accent,
                        title: "Entrenos",
                        description: "Importa tus carreras directamente desde el Apple Watch o cualquier app compatible."
                    )
                }

                if vm.healthPermissionsGranted {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Acceso concedido")
                            .font(DS.Typo.rowTitle)
                            .foregroundStyle(DS.Colors.textPrimary)
                    }
                    .padding(DS.Layout.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
                } else {
                    Button {
                        Task {
                            let granted = await healthService.requestAuthorization()
                            vm.healthPermissionsGranted = granted
                            vm.healthPermissionsRequested = true
                        }
                    } label: {
                        Label("Autorizar Apple Health", systemImage: "heart.text.square.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Continuar sin Apple Health") {
                        vm.healthPermissionsGranted = false
                        vm.healthPermissionsRequested = true
                    }
                    .font(DS.Typo.body)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DS.Layout.screenPadding)
            .padding(.vertical, 24)
        }
    }

    private func permissionCard(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 32)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(DS.Typo.rowTitle)
                Text(description).font(DS.Typo.body).foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .padding(DS.Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }
}
