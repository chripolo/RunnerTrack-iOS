import Foundation
import SwiftData

@Model
final class DailyMetric {
    var date: Date
    var restingHR: Int?                 // HealthKit — lectura automática
    var hrv: Double?                    // HealthKit — ms
    var weight: Double?                 // manual o HealthKit
    var sleepHours: Double?             // HealthKit
    var subjectiveFatigue: Int?         // manual 1–5

    init(date: Date) {
        self.date = date
    }
}
