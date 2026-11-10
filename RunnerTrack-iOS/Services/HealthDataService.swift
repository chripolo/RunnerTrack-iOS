import Foundation

// Abstracción sobre HealthKit — permite desarrollar en simulador sin Developer Program.
// La app inyecta Mock en DEBUG y Real en RELEASE desde el entry point.

/// `nonisolated` + `Sendable`: el protocolo no hereda el aislamiento MainActor por defecto del target,
/// así que puede implementarlo un `actor` y usarse desde cualquier contexto de concurrencia.
nonisolated protocol HealthDataService: Sendable {
    func getRestingHR() async -> Int?
    func getHRV() async -> Double?
    func getSteps() async -> Int?
    func getSleepHours() async -> Double?
}
