import SwiftUI

// =====================================================================
// Sistema de diseño RunnerTrack — "Volt sobre asfalto"
// Base oscura (asfalto nocturno) + un único acento volt eléctrico.
// Toda View consume colores y tipografía desde aquí — nunca hardcodear.
// =====================================================================

enum DS {

    // MARK: - Colores

    enum Colors {
        /// Fondo principal — asfalto nocturno
        static let background = Color(red: 0.051, green: 0.059, blue: 0.078)        // #0D0F14
        /// Superficie de tarjeta
        static let surface = Color(red: 0.086, green: 0.102, blue: 0.133)           // #161A22
        /// Superficie elevada (sheets, filas destacadas)
        static let surfaceElevated = Color(red: 0.125, green: 0.145, blue: 0.184)   // #20252F
        /// Acento único de la app — volt eléctrico
        static let accent = Color(red: 0.843, green: 1.0, blue: 0.243)              // #D7FF3E
        /// Texto principal
        static let textPrimary = Color(red: 0.949, green: 0.957, blue: 0.969)       // #F2F4F7
        /// Texto secundario / etiquetas
        static let textSecondary = Color(red: 0.541, green: 0.576, blue: 0.651)     // #8A93A6
        /// Separadores sutiles
        static let divider = Color.white.opacity(0.06)

        /// Color por zona de entrenamiento — frío a caliente
        static func zone(_ zone: Zone) -> Color {
            switch zone {
            case .z1: return Color(red: 0.310, green: 0.639, blue: 1.0)    // azul recuperación
            case .z2: return Color(red: 0.239, green: 0.863, blue: 0.518)  // verde aeróbico
            case .z3: return Color(red: 1.0, green: 0.839, blue: 0.039)    // amarillo tempo
            case .z4: return Color(red: 1.0, green: 0.624, blue: 0.039)    // naranja umbral
            case .z5: return Color(red: 1.0, green: 0.271, blue: 0.227)    // rojo máximo
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
                    .tracking(1.2)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(DS.Typo.metricMedium)
                    .foregroundStyle(DS.Colors.textPrimary)
                Text(unit)
                    .font(DS.Typo.metricSmall)
                    .foregroundStyle(DS.Colors.textSecondary)
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
