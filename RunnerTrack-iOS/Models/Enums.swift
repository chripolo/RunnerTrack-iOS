import Foundation

enum RaceType: String, Codable, CaseIterable {
    case tenK = "10K"
    case halfMarathon = "Media Maratón"
    case marathon = "Maratón"
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
