import SwiftData
import Foundation

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var planName: String
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.session)
    var exerciseLogs: [ExerciseLog]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        planName: String,
        startTime: Date = .now,
        endTime: Date? = nil,
        isCompleted: Bool = false,
        notes: String? = nil,
        exerciseLogs: [ExerciseLog] = []
    ) {
        self.id = id
        self.date = date
        self.planName = planName
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.notes = notes
        self.exerciseLogs = exerciseLogs
    }

    var durationMinutes: Int {
        guard let end = endTime else { return 0 }
        return Int(end.timeIntervalSince(startTime) / 60)
    }

    var totalVolume: Double {
        exerciseLogs.compactMap { log -> Double? in
            guard let weight = log.weight, let reps = log.reps else { return nil }
            return weight * Double(reps)
        }.reduce(0, +)
    }

    var completedExerciseCount: Int {
        exerciseLogs.filter { $0.isCompleted }.count
    }
}
