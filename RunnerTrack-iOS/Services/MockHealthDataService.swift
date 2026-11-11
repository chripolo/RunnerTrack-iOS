import Foundation

#if DEBUG
/// Valores mock basados en el perfil de ejemplo (CLAUDE.md §8)
struct MockHealthDataService: HealthDataService {
    func getRestingHR() async -> Int? { 48 }
    func getHRV() async -> Double? { 58.0 }
    func getSteps() async -> Int? { 8500 }
    func getSleepHours() async -> Double? { 7.2 }

    func getRecentWorkouts(limit: Int) async -> [HealthWorkout] {
        let now = Date.now
        return [
            HealthWorkout(id: UUID(), date: now.addingTimeInterval(-2 * 86400), durationMinutes: 50, distanceKm: 8.1, avgHR: 148),
            HealthWorkout(id: UUID(), date: now.addingTimeInterval(-4 * 86400), durationMinutes: 42, distanceKm: 6.8, avgHR: 152),
            HealthWorkout(id: UUID(), date: now.addingTimeInterval(-7 * 86400), durationMinutes: 72, distanceKm: 11.5, avgHR: 145),
        ]
    }
}
#endif
