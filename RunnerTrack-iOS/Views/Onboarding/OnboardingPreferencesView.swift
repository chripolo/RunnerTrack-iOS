import SwiftUI

struct OnboardingPreferencesView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Preferencias")
                    .font(.largeTitle.bold())
                Text("Ajusta cómo quieres ver tu entrenamiento.")
                    .font(.body)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 8)

            Form {
                Section {
                    Picker("Inicio de semana", selection: $vm.weekStartDay) {
                        Text("Lunes").tag(2)
                        Text("Domingo").tag(1)
                    }
                } header: {
                    Text("Semana")
                } footer: {
                    Text("Determina cómo se agrupan tus sesiones y el volumen semanal.")
                }

                Section {
                    infoRow(icon: "heart.fill", color: DS.Colors.zone(.z1),
                            title: "FC Reposo", detail: "Para detectar fatiga acumulada")
                    infoRow(icon: "waveform.path.ecg", color: DS.Colors.zone(.z2),
                            title: "HRV", detail: "Variabilidad cardíaca — señal de recuperación")
                    infoRow(icon: "figure.run", color: DS.Colors.accent,
                            title: "Entrenos", detail: "Duración, distancia y ritmo de cada sesión")
                } header: {
                    Text("Apple Health — datos que se leerán")
                } footer: {
                    Text("Puedes revocar el acceso en cualquier momento desde Ajustes del sistema.")
                }
            }
        }
    }

    private func infoRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(DS.Typo.rowTitle)
                Text(detail).font(DS.Typo.body).foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}
