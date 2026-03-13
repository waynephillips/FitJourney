import SwiftData
import Foundation

enum ExerciseType: String, Codable, CaseIterable {
    case warmup   = "warmup"
    case strength = "strength"
    case cardio   = "cardio"
    case core     = "core"
    case circuit  = "circuit"

    var displayName: String {
        switch self {
        case .warmup:   return "Warm-up"
        case .strength: return "Strength"
        case .cardio:   return "Cardio"
        case .core:     return "Core"
        case .circuit:  return "Circuit"
        }
    }
}

enum KneeSafety: String, Codable, CaseIterable {
    case safe    = "safe"
    case caution = "caution"
    case avoid   = "avoid"

    var displayName: String {
        switch self {
        case .safe:    return "Safe"
        case .caution: return "Caution"
        case .avoid:   return "Avoid"
        }
    }

    var icon: String {
        switch self {
        case .safe:    return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .avoid:   return "xmark.circle.fill"
        }
    }
}

@Model
final class Exercise {
    var id: UUID
    var name: String
    var detail: String
    var sets: String
    var type: ExerciseType
    var kneeSafety: KneeSafety
    var sortOrder: Int
    var plan: WorkoutPlan?

    init(
        id: UUID = UUID(),
        name: String,
        detail: String,
        sets: String,
        type: ExerciseType,
        kneeSafety: KneeSafety,
        sortOrder: Int,
        plan: WorkoutPlan? = nil
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.sets = sets
        self.type = type
        self.kneeSafety = kneeSafety
        self.sortOrder = sortOrder
        self.plan = plan
    }
}
