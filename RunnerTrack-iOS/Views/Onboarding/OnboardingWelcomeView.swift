import SwiftUI

struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 12) {
                Text("Bienvenido a RunnerTrack")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("Tu plan personalizado hacia el maratón.\nSin tecnología de por medio — solo tú y tu entrenamiento.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}
