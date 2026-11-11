import Foundation

enum RaceType: String, Codable, CaseIterable {
    case tenK = "10K"
    case halfMarathon = "Media Maratón"
    case marathon = "Maratón"
}

enum RaceGoalTier: String, Codable, CaseIterable {
    case conservative = "Conservador"
    case moderate     = "Moderado"
    case ambitious    = "Ambicioso"

    /// Ritmo objetivo en seg/km y tiempo de llegada estimado según tipo de carrera
    func targetPace(for race: RaceType) -> Double {
        switch (race, self) {
        // Maratón (42,195 km)
        case (.marathon, .conservative): return 363  // 4h15' = 6'03"/km
        case (.marathon, .moderate):     return 348  // 4h05' = 5'48"/km
        case (.marathon, .ambitious):    return 341  // sub-4h = 5'41"/km
        // Media maratón (21,0975 km)
        case (.halfMarathon, .conservative): return 341  // 2h00' = 5'41"/km
        case (.halfMarathon, .moderate):     return 327  // 1h55' = 5'27"/km
        case (.halfMarathon, .ambitious):    return 313  // 1h50' = 5'13"/km
        // 10K
        case (.tenK, .conservative): return 330  // 55' = 5'30"/km
        case (.tenK, .moderate):     return 300  // 50' = 5'00"/km
        case (.tenK, .ambitious):    return 270  // 45' = 4'30"/km
        }
    }

    /// Descripción del tiempo de llegada para mostrar en la UI
    func finishTime(for race: RaceType) -> String {
        switch (race, self) {
        case (.marathon, .conservative): return "4h15'"
        case (.marathon, .moderate):     return "4h05'"
        case (.marathon, .ambitious):    return "sub 4h"
        case (.halfMarathon, .conservative): return "2h00'"
        case (.halfMarathon, .moderate):     return "1h55'"
        case (.halfMarathon, .ambitious):    return "1h50'"
        case (.tenK, .conservative): return "55'"
        case (.tenK, .moderate):     return "50'"
        case (.tenK, .ambitious):    return "45'"
        }
    }
}

enum SessionType: String, Codable, CaseIterable {
    case easyRun = "Rodaje Suave"
    case longRun = "Rodaje Largo"
    case tempo = "Tempo"
    case intervals = "Intervalos"
    case strength = "Fuerza"
    case rest = "Descanso"
}

enum Zone: String, Codable, CaseIterable {
    case z1 = "Z1"
    case z2 = "Z2"
    case z3 = "Z3"
    case z4 = "Z4"
    case z5 = "Z5"
}
