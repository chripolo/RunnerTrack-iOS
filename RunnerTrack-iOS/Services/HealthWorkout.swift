import Foundation

/// Entreno de running leído de HealthKit — tipo propio sin dependencia de HealthKit en la capa de protocolo
struct HealthWorkout: Identifiable {
    let id: UUID
    let date: Date
    let durationMinutes: Int
    let distanceKm: Double?
    let avgHR: Int?
}
