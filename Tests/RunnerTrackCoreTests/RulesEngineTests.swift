import Testing
@testable import RunnerTrackCore

@Suite("RulesEngine")
struct RulesEngineTests {

    private let mean = 48

    @Test("Sin datos no hay alerta")
    func noDataIsGreen() {
        #expect(RulesEngine.evaluate(restingHR: nil, personalMeanRestingHR: mean, hrv: nil) == .green)
    }

    @Test("Valores normales no generan alerta")
    func normalValuesAreGreen() {
        #expect(RulesEngine.evaluate(restingHR: 48, personalMeanRestingHR: mean, hrv: 58) == .green)
    }

    @Test("HRV por debajo de 45 ms es alerta roja")
    func criticalHRVIsRed() {
        #expect(RulesEngine.evaluate(restingHR: 48, personalMeanRestingHR: mean, hrv: 44.9) == .red)
    }

    @Test("HRV de 45 ms exactos ya no es roja, es amarilla")
    func hrvAtRedBoundaryIsYellow() {
        #expect(RulesEngine.evaluate(restingHR: 48, personalMeanRestingHR: mean, hrv: 45) == .yellow)
    }

    @Test("HRV entre 45 y 50 ms es alerta amarilla")
    func lowHRVIsYellow() {
        #expect(RulesEngine.evaluate(restingHR: 48, personalMeanRestingHR: mean, hrv: 49.9) == .yellow)
    }

    @Test("HRV de 50 ms exactos no genera alerta")
    func hrvAtYellowBoundaryIsGreen() {
        #expect(RulesEngine.evaluate(restingHR: 48, personalMeanRestingHR: mean, hrv: 50) == .green)
    }

    @Test("FC en reposo media + 5 no alerta; media + 6 sí (amarilla)")
    func restingHRBoundary() {
        #expect(RulesEngine.evaluate(restingHR: 53, personalMeanRestingHR: mean, hrv: 58) == .green)
        #expect(RulesEngine.evaluate(restingHR: 54, personalMeanRestingHR: mean, hrv: 58) == .yellow)
    }

    @Test("La HRV crítica tiene prioridad sobre la FC en reposo alta")
    func criticalHRVWinsOverRestingHR() {
        #expect(RulesEngine.evaluate(restingHR: 70, personalMeanRestingHR: mean, hrv: 40) == .red)
    }

    @Test("FC en reposo alta sin dato de HRV es amarilla")
    func highRestingHRWithoutHRV() {
        #expect(RulesEngine.evaluate(restingHR: 60, personalMeanRestingHR: mean, hrv: nil) == .yellow)
    }

    @Test("Cada nivel tiene título y mensaje")
    func alertLevelTexts() {
        #expect(AlertLevel.green.title == "Sin alertas")
        #expect(AlertLevel.yellow.title == "Alerta leve")
        #expect(AlertLevel.red.title == "Alerta crítica")
        #expect(!AlertLevel.green.message.isEmpty)
        #expect(!AlertLevel.yellow.message.isEmpty)
        #expect(!AlertLevel.red.message.isEmpty)
    }
}
