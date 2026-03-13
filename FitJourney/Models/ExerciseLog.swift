import SwiftData
import Foundation

@Model
final class ExerciseLog {
    var id: UUID
    var exerciseName: String
    var setNumber: Int
    var reps: Int?
    var weight: Double?
    var durationSeconds: Int?
    var isCompleted: Bool
    var session: WorkoutSession?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        setNumber: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        durationSeconds: Int? = nil,
        isCompleted: Bool = false,
        session: WorkoutSession? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.durationSeconds = durationSeconds
        self.isCompleted = isCompleted
        self.session = session
    }

    var volumeLbs: Double? {
        guard let w = weight, let r = reps else { return nil }
        return w * Double(r)
    }

    var displayDuration: String {
        guard let seconds = durationSeconds else { return "" }
        let mins = seconds / 60
        let secs = seconds % 60
        return mins > 0 ? "\(mins)m \(secs)s" : "\(secs)s"
    }
}
