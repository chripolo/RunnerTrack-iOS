import Foundation

#if DEBUG
/// Valores mock basados en el perfil de ejemplo (CLAUDE.md §8)
struct MockHealthDataService: HealthDataService {
    func getRestingHR() async -> Int? { 48 }
    func getHRV() async -> Double? { 58.0 }
    func getSteps() async -> Int? { 8500 }
    func getSleepHours() async -> Double? { 7.2 }
}
#endif
