import SwiftData
import Foundation

@Model
final class WorkoutPlan {
    var id: UUID
    var name: String
    var dayOfWeek: String
    var duration: String
    var focusArea: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade, inverse: \Exercise.plan)
    var exercises: [Exercise]

    init(
        id: UUID = UUID(),
        name: String,
        dayOfWeek: String,
        duration: String,
        focusArea: String,
        sortOrder: Int,
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.duration = duration
        self.focusArea = focusArea
        self.sortOrder = sortOrder
        self.exercises = exercises
    }

    var sortedExercises: [Exercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    var exerciseCount: Int { exercises.count }

    var kneeSafetyCount: Int {
        exercises.filter { $0.kneeSafety == .safe }.count
    }

    var hasCautionExercises: Bool {
        exercises.contains { $0.kneeSafety == .caution }
    }
}
