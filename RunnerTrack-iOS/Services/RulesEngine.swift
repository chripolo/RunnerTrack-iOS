import Foundation

/// Nivel de alerta del motor de reglas
enum AlertLevel {
    case green
    case yellow
    case red

    var title: String {
        switch self {
        case .green: return "Sin alertas"
        case .yellow: return "Alerta leve"
        case .red: return "Alerta crítica"
        }
    }

    var message: String {
        switch self {
        case .green: return "Todo en orden. Entrena según el plan."
        case .yellow: return "Señales de fatiga. Considera reducir el volumen."
        case .red: return "Recuperación comprometida. Recomendado 2–3 días de descanso."
        }
    }
}

// Motor de reglas de sobreentrenamiento (CLAUDE.md §6) — funciones puras
// Evaluación de un solo día — TODO: S5 — evaluar rachas de 3+/4+ días con histórico DailyMetric
enum RulesEngine {

    static func evaluate(restingHR: Int?, personalMeanRestingHR: Int, hrv: Double?) -> AlertLevel {
        if let hrv, hrv < 45 { return .red }
        if let hrv, hrv < 50 { return .yellow }
        if let restingHR, restingHR > personalMeanRestingHR + 5 { return .yellow }
        return .green
    }
}
