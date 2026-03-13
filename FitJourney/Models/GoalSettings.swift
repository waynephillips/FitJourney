import SwiftData
import Foundation

@Model
final class GoalSettings {
    var startWeight: Double
    var targetWeight: Double
    var startDate: Date
    var targetDate: Date
    var weeklyGoalLbs: Double
    var dailyCalorieTarget: Int
    var proteinTargetGrams: Int

    init(
        startWeight: Double = 220.0,
        targetWeight: Double = 180.0,
        startDate: Date = .now,
        targetDate: Date = {
            var components = DateComponents()
            components.year = 2026
            components.month = 12
            components.day = 31
            return Calendar.current.date(from: components) ?? .now
        }(),
        weeklyGoalLbs: Double = 1.0,
        dailyCalorieTarget: Int = 2000,
        proteinTargetGrams: Int = 160
    ) {
        self.startWeight = startWeight
        self.targetWeight = targetWeight
        self.startDate = startDate
        self.targetDate = targetDate
        self.weeklyGoalLbs = weeklyGoalLbs
        self.dailyCalorieTarget = dailyCalorieTarget
        self.proteinTargetGrams = proteinTargetGrams
    }

    var totalLbsToLose: Double { startWeight - targetWeight }
    var lbsLostSoFar: Double { 0 } // Computed from BodyMetric records
    var percentComplete: Double {
        guard totalLbsToLose > 0 else { return 0 }
        return min(lbsLostSoFar / totalLbsToLose, 1.0)
    }
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: .now, to: targetDate).day ?? 0
    }
}
