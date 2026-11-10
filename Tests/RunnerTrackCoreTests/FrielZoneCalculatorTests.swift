import Testing
@testable import RunnerTrackCore

@Suite("FrielZoneCalculator")
struct FrielZoneCalculatorTests {

    @Test("Umbral 172 y máxima 178 reproducen la tabla de zonas")
    func zonesForThreshold172() {
        let zones = FrielZoneCalculator.zones(thresholdHR: 172, maxHR: 178)

        #expect(zones.map(\.zone) == [.z1, .z2, .z3, .z4, .z5])
        #expect(zones.map(\.rangeText) == [
            "0–144 bpm",
            "146–153 bpm",
            "155–162 bpm",
            "163–170 bpm",
            "172–178 bpm",
        ])
    }

    @Test("Redondea al entero más cercano, no trunca (172 × 0,94 = 161,68 → 162)")
    func roundsInsteadOfTruncating() {
        #expect(FrielZoneCalculator.rangeText(for: .z3, thresholdHR: 172, maxHR: 178) == "155–162 bpm")
    }

    @Test("Otro umbral produce rangos coherentes")
    func zonesForThreshold160() {
        let zones = FrielZoneCalculator.zones(thresholdHR: 160, maxHR: 170)

        #expect(zones.map(\.rangeText) == [
            "0–134 bpm",
            "136–142 bpm",
            "144–150 bpm",
            "152–158 bpm",
            "160–170 bpm",
        ])
    }

    @Test("rangeText(for:) devuelve el rango de la zona pedida")
    func rangeTextForZone() {
        #expect(FrielZoneCalculator.rangeText(for: .z1, thresholdHR: 172, maxHR: 178) == "0–144 bpm")
        #expect(FrielZoneCalculator.rangeText(for: .z5, thresholdHR: 172, maxHR: 178) == "172–178 bpm")
    }

    @Test("Cada zona tiene un id único y estable")
    func zoneIdsAreUnique() {
        let ids = FrielZoneCalculator.zones(thresholdHR: 172, maxHR: 178).map(\.id)
        #expect(Set(ids).count == ids.count)
        #expect(ids == ["Z1", "Z2", "Z3", "Z4", "Z5"])
    }
}
