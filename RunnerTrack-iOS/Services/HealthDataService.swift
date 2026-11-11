import Foundation

// Abstracción sobre HealthKit — permite desarrollar en simulador sin Developer Program.
// La app inyecta Mock en DEBUG y Real en RELEASE desde el entry point.

protocol HealthDataService {
    func requestAuthorization() async -> Bool
    func getRestingHR() async -> Int?
    func getHRV() async -> Double?
    func getSteps() async -> Int?
    func getSleepHours() async -> Double?
    func getRecentWorkouts(limit: Int) async -> [HealthWorkout]
    /// FC reposo del último N días — una muestra por día, ordenada de más antiguo a más reciente
    func getDailyRestingHR(days: Int) async -> [(date: Date, bpm: Int)]
}
