import SwiftUI

/// Detalle de una sesión planificada — se presenta como sheet desde el dashboard
struct SessionDetailSheet: View {
    let session: PlannedSessionPreview
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cabecera con día y título
            VStack(alignment: .leading, spacing: 4) {
                Text(session.day.uppercased())
                    .font(DS.Typo.label)
                    .tracking(1.5)
                    .foregroundStyle(DS.Colors.textSecondary)
                Text(session.title)
                    .font(DS.Typo.screenTitle)
                    .foregroundStyle(DS.Colors.textPrimary)
            }

            // Zona y duración
            HStack(spacing: 12) {
                if let zone = session.zone {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(DS.Colors.zone(zone))
                            .frame(width: 10, height: 10)
                        Text("Zona \(zone.rawValue)")
                            .font(DS.Typo.metricSmall)
                            .foregroundStyle(DS.Colors.textPrimary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(DS.Colors.surfaceElevated, in: Capsule())
                }
                if let duration = session.durationMin {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DS.Colors.accent)
                        Text("\(duration) min")
                            .font(DS.Typo.metricSmall)
                            .foregroundStyle(DS.Colors.textPrimary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(DS.Colors.surfaceElevated, in: Capsule())
                }
            }

            // Descripción
            Text(session.detail)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textSecondary)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(DS.Colors.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
