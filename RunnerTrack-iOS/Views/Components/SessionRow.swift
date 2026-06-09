import SwiftUI

/// Fila de sesión semanal — compartida entre Dashboard y Plan
struct SessionRow: View {
    let template: SessionTemplate
    var isCompleted: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(template.zone.map(DS.Colors.zone) ?? DS.Colors.textSecondary.opacity(0.3))
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.day)
                    .font(DS.Typo.label)
                    .tracking(1.0)
                    .foregroundStyle(DS.Colors.textSecondary)
                Text(template.title)
                    .font(DS.Typo.rowTitle)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .strikethrough(isCompleted, color: DS.Colors.textSecondary)
            }

            Spacer()

            if let duration = template.durationMin {
                Text("\(duration)'")
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Colors.accent)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.Colors.textSecondary.opacity(0.5))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
