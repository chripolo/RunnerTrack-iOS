import SwiftUI

// =====================================================================
// Sistema de diseño RunnerTrack — "Aurora sobre Océano"
// Paleta Aurora: Deep Ocean + Aurora Teal como acento primario.
// Toda View consume colores y tipografía desde aquí — nunca hardcodear.
// =====================================================================

enum DS {

    // MARK: - Colores

    enum Colors {
        /// Fondo principal — Deep Ocean
        static let background = Color(red: 0.031, green: 0.102, blue: 0.114)        // #081A1D
        /// Superficie de tarjeta — Ocean Surface
        static let surface = Color(red: 0.063, green: 0.165, blue: 0.169)           // #102A2B
        /// Superficie elevada (sheets, filas destacadas)
        static let surfaceElevated = Color(red: 0.094, green: 0.208, blue: 0.212)   // #183536
        /// Acento principal — Aurora Teal
        static let accent = Color(red: 0.000, green: 0.902, blue: 0.765)            // #00E6C3
        /// Texto principal — Cloud
        static let textPrimary = Color(red: 0.957, green: 0.965, blue: 0.973)       // #F4F6F8
        /// Texto secundario / etiquetas — Mist
        static let textSecondary = Color(red: 0.580, green: 0.580, blue: 0.659)     // #9494A8
        /// Separadores sutiles
        static let divider = Color.white.opacity(0.06)

        /// Color por nivel de alerta del motor de reglas
        static func alert(_ level: AlertLevel) -> Color {
            switch level {
            case .green:  return Color(red: 0.000, green: 0.902, blue: 0.765) // Aurora Teal #00E6C3
            case .yellow: return Color(red: 1.000, green: 0.722, blue: 0.420) // Threshold   #FFB86B
            case .red:    return Color(red: 0.941, green: 0.439, blue: 0.376) // Intervals   #F07060
            }
        }

        /// Color por zona de entrenamiento Friel — paleta Aurora semántica
        static func zone(_ zone: Zone) -> Color {
            switch zone {
            case .z1: return Color(red: 0.522, green: 0.718, blue: 0.922) // Recovery  #85B7EB
            case .z2: return Color(red: 0.298, green: 0.961, blue: 0.824) // Aeróbico  #4CF5D2
            case .z3: return Color(red: 0.655, green: 0.545, blue: 0.980) // Tempo     #A78BFA
            case .z4: return Color(red: 1.000, green: 0.722, blue: 0.420) // Umbral    #FFB86B
            case .z5: return Color(red: 0.941, green: 0.439, blue: 0.376) // Máximo    #F07060
            }
        }
    }

    // MARK: - Tipografía
    // Jerarquía: título de pantalla → dato métrico (rounded, dígitos fijos) → etiqueta

    enum Typo {
        /// Título grande de pantalla
        static let screenTitle = Font.system(size: 30, weight: .heavy)
        /// Subtítulo / saludo
        static let subtitle = Font.system(size: 16, weight: .medium)
        /// Dato métrico protagonista (días restantes, bpm)
        static let metricLarge = Font.system(size: 44, weight: .bold, design: .rounded).monospacedDigit()
        /// Dato métrico en tarjeta
        static let metricMedium = Font.system(size: 26, weight: .bold, design: .rounded).monospacedDigit()
        /// Valor numérico pequeño (rangos de zona)
        static let metricSmall = Font.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit()
        /// Etiqueta de sección / tarjeta — usar siempre en mayúsculas con tracking
        static let label = Font.system(size: 12, weight: .semibold)
        /// Cuerpo de texto
        static let body = Font.system(size: 15, weight: .regular)
        /// Título de fila
        static let rowTitle = Font.system(size: 16, weight: .semibold)
    }

    // MARK: - Métricas de layout

    enum Layout {
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
    }
}

// MARK: - Componentes reutilizables

/// Cabecera de sección: barra volt + etiqueta en mayúsculas con tracking
struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DS.Colors.accent)
                .frame(width: 4, height: 14)
            Text(title.uppercased())
                .font(DS.Typo.label)
                .tracking(1.5)
                .foregroundStyle(DS.Colors.textSecondary)
            Spacer()
        }
    }
}

/// Tarjeta de métrica: etiqueta + valor grande + unidad
struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.Colors.accent)
                Text(label.uppercased())
                    .font(DS.Typo.label)
                    .tracking(0.8)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(DS.Typo.metricMedium)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(unit)
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Layout.cardPadding)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Layout.cardCornerRadius))
    }
}

/// Fila de zona Friel: indicador de color + código + nombre + rango
struct ZoneRow: View {
    let zone: Zone
    let name: String
    let rangeText: String

    var body: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(DS.Colors.zone(zone))
                .frame(width: 4, height: 28)
            Text(zone.rawValue)
                .font(DS.Typo.metricSmall)
                .foregroundStyle(DS.Colors.zone(zone))
                .frame(width: 28, alignment: .leading)
            Text(name)
                .font(DS.Typo.body)
                .foregroundStyle(DS.Colors.textPrimary)
            Spacer()
            Text(rangeText)
                .font(DS.Typo.metricSmall)
                .foregroundStyle(DS.Colors.textSecondary)
        }
        .padding(.vertical, 6)
    }
}
