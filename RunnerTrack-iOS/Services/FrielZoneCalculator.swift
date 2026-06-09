import Foundation

/// Rango de zona Friel listo para presentar
struct ZoneDisplay: Identifiable {
    let zone: Zone
    let name: String
    let rangeText: String
    var id: String { zone.rawValue }
}

// Cálculo de zonas Friel (CLAUDE.md §5) — funciones puras, testeables
enum FrielZoneCalculator {

    static func zones(thresholdHR: Int, maxHR: Int) -> [ZoneDisplay] {
        let t = Double(thresholdHR)
        let bound = { (factor: Double) in Int((t * factor).rounded()) }
        return [
            ZoneDisplay(zone: .z1, name: "Recuperación", rangeText: "0–\(bound(0.84)) bpm"),
            ZoneDisplay(zone: .z2, name: "Aeróbico", rangeText: "\(bound(0.85))–\(bound(0.89)) bpm"),
            ZoneDisplay(zone: .z3, name: "Tempo", rangeText: "\(bound(0.90))–\(bound(0.94)) bpm"),
            ZoneDisplay(zone: .z4, name: "Umbral", rangeText: "\(bound(0.95))–\(bound(0.99)) bpm"),
            ZoneDisplay(zone: .z5, name: "Máximo", rangeText: "\(thresholdHR)–\(maxHR) bpm"),
        ]
    }

    static func rangeText(for zone: Zone, thresholdHR: Int, maxHR: Int) -> String {
        zones(thresholdHR: thresholdHR, maxHR: maxHR)
            .first { $0.zone == zone }?.rangeText ?? "—"
    }
}
