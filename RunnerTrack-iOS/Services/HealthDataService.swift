import Foundation

// Abstracción sobre HealthKit — permite desarrollar en simulador sin Developer Program.
// La app inyecta Mock en DEBUG y Real en RELEASE (ver HealthServiceFactory).

protocol HealthDataService {
    func getRestingHR() async -> Int?
    func getHRV() async -> Double?
    func getSteps() async -> Int?
    func getSleepHours() async -> Double?
}

/// Valores mock basados en el perfil de ejemplo
struct MockHealthDataService: HealthDataService {
    func getRestingHR() async -> Int? { 48 }
    func getHRV() async -> Double? { 58.0 }
    func getSteps() async -> Int? { 8500 }
    func getSleepHours() async -> Double? { 7.2 }
}

/// Implementación real sobre HealthKit
struct RealHealthDataService: HealthDataService {
    // TODO: S3 — integrar HealthKit real (FC reposo, HRV, pasos, sueño)
    func getRestingHR() async -> Int? { nil }
    func getHRV() async -> Double? { nil }
    func getSteps() async -> Int? { nil }
    func getSleepHours() async -> Double? { nil }
}

enum HealthServiceFactory {
    static func make() -> HealthDataService {
        #if DEBUG
        return MockHealthDataService()
        #else
        return RealHealthDataService()
        #endif
    }
}
