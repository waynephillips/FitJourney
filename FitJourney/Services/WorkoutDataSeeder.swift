import SwiftData
import Foundation

/// Seeds the 4 predefined workout plans on first app launch.
/// Safe to call on every launch — checks UserDefaults + existing data before inserting.
@MainActor
struct WorkoutDataSeeder {

    private static let seededKey = "com.wayne.fitjourney.hasSeededWorkouts"

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }

        // Guard against double-seeding (e.g. if UserDefaults was cleared)
        let descriptor = FetchDescriptor<WorkoutPlan>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else {
            UserDefaults.standard.set(true, forKey: seededKey)
            return
        }

        let plans = [mondayPlan(), thursdayPlan(), fridayPlan(), weekendPlan()]
        for plan in plans { context.insert(plan) }
        try? context.save()

        UserDefaults.standard.set(true, forKey: seededKey)
    }

    // MARK: - Monday — Upper Body Strength (45-50 min)

    private static func mondayPlan() -> WorkoutPlan {
        let plan = WorkoutPlan(
            name: "Upper Body Strength",
            dayOfWeek: "Monday",
            duration: "45-50 min",
            focusArea: "Chest, Back, Shoulders, Arms + Core",
            sortOrder: 0
        )
        plan.exercises = [
            Exercise(name: "Treadmill Walk",
                     detail: "3.0–3.5 mph, flat or slight incline",
                     sets: "5 min", type: .warmup, kneeSafety: .safe, sortOrder: 0, plan: plan),
            Exercise(name: "Dumbbell Bench Press",
                     detail: "Or Smith machine. Control the negative.",
                     sets: "3 × 10-12", type: .strength, kneeSafety: .safe, sortOrder: 1, plan: plan),
            Exercise(name: "Lat Pulldown",
                     detail: "Wide grip. Squeeze shoulder blades.",
                     sets: "3 × 10-12", type: .strength, kneeSafety: .safe, sortOrder: 2, plan: plan),
            Exercise(name: "Seated Shoulder Press",
                     detail: "Dumbbells or Smith machine.",
                     sets: "3 × 10-12", type: .strength, kneeSafety: .safe, sortOrder: 3, plan: plan),
            Exercise(name: "Seated Cable Row",
                     detail: "Back straight. Pull to lower chest.",
                     sets: "3 × 10-12", type: .strength, kneeSafety: .safe, sortOrder: 4, plan: plan),
            Exercise(name: "Dumbbell Bicep Curls",
                     detail: "Alternating arms. No swinging.",
                     sets: "2 × 12-15", type: .strength, kneeSafety: .safe, sortOrder: 5, plan: plan),
            Exercise(name: "Tricep Pushdown",
                     detail: "Rope or bar. Elbows pinned to sides.",
                     sets: "2 × 12-15", type: .strength, kneeSafety: .safe, sortOrder: 6, plan: plan),
            Exercise(name: "Plank Hold",
                     detail: "On forearms. Build up over weeks.",
                     sets: "3 × 20-30s", type: .core, kneeSafety: .safe, sortOrder: 7, plan: plan),
            Exercise(name: "Incline Walk",
                     detail: "10–12% incline, 3.0–3.5 mph",
                     sets: "10-12 min", type: .cardio, kneeSafety: .safe, sortOrder: 8, plan: plan),
        ]
        return plan
    }

    // MARK: - Thursday — Lower Body Strength, Knee-Safe (45-50 min)

    private static func thursdayPlan() -> WorkoutPlan {
        let plan = WorkoutPlan(
            name: "Lower Body Strength, Knee-Safe",
            dayOfWeek: "Thursday",
            duration: "45-50 min",
            focusArea: "Legs, Glutes, Hips + Core",
            sortOrder: 1
        )
        plan.exercises = [
            Exercise(name: "Upright Bike",
                     detail: "Light resistance. Blood flow to knees.",
                     sets: "5 min", type: .warmup, kneeSafety: .safe, sortOrder: 0, plan: plan),
            Exercise(name: "Leg Press",
                     detail: "Do NOT go past 90° knee bend!",
                     sets: "3 × 10-12", type: .strength, kneeSafety: .caution, sortOrder: 1, plan: plan),
            Exercise(name: "Lying Hamstring Curl",
                     detail: "Slow and controlled.",
                     sets: "3 × 12-15", type: .strength, kneeSafety: .safe, sortOrder: 2, plan: plan),
            Exercise(name: "Hip Abduction Machine",
                     detail: "Opens outward. Hip stabilizers.",
                     sets: "3 × 15", type: .strength, kneeSafety: .safe, sortOrder: 3, plan: plan),
            Exercise(name: "Hip Adduction Machine",
                     detail: "Squeezes inward. Inner knee support.",
                     sets: "3 × 15", type: .strength, kneeSafety: .safe, sortOrder: 4, plan: plan),
            Exercise(name: "Glute Bridge",
                     detail: "Squeeze at top. Add dumbbell to progress.",
                     sets: "3 × 15", type: .strength, kneeSafety: .safe, sortOrder: 5, plan: plan),
            Exercise(name: "Standing Calf Raises",
                     detail: "Smith machine or calf machine. Slow.",
                     sets: "3 × 15-20", type: .strength, kneeSafety: .safe, sortOrder: 6, plan: plan),
            Exercise(name: "Dead Bug",
                     detail: "On back, opposite arm/leg extend.",
                     sets: "3 × 10/side", type: .core, kneeSafety: .safe, sortOrder: 7, plan: plan),
            Exercise(name: "Incline Walk",
                     detail: "10–12% incline, 3.0–3.5 mph",
                     sets: "10-12 min", type: .cardio, kneeSafety: .safe, sortOrder: 8, plan: plan),
        ]
        return plan
    }

    // MARK: - Friday — Cardio + Core (40-45 min)

    private static func fridayPlan() -> WorkoutPlan {
        let plan = WorkoutPlan(
            name: "Cardio + Core",
            dayOfWeek: "Friday",
            duration: "40-45 min",
            focusArea: "Cardiovascular Fitness + Core",
            sortOrder: 2
        )
        plan.exercises = [
            Exercise(name: "Upright Stationary Bike",
                     detail: "2 min easy / 1 min harder intervals.",
                     sets: "15 min", type: .cardio, kneeSafety: .safe, sortOrder: 0, plan: plan),
            Exercise(name: "Elliptical",
                     detail: "Low-moderate resistance. Stop if knee pain.",
                     sets: "12-15 min", type: .cardio, kneeSafety: .caution, sortOrder: 1, plan: plan),
            Exercise(name: "Incline Treadmill Walk",
                     detail: "Alt: 2 min 12% incline / 1 min 4%",
                     sets: "10 min", type: .cardio, kneeSafety: .safe, sortOrder: 2, plan: plan),
            Exercise(name: "Bicycle Crunches",
                     detail: "Slow. Elbow to opposite knee.",
                     sets: "3 × 15/side", type: .core, kneeSafety: .safe, sortOrder: 3, plan: plan),
            Exercise(name: "Plank Hold",
                     detail: "Build toward 45–60 sec.",
                     sets: "3 × 30s", type: .core, kneeSafety: .safe, sortOrder: 4, plan: plan),
            Exercise(name: "Cable Woodchop",
                     detail: "High-to-low. Rotational core.",
                     sets: "2 × 12/side", type: .core, kneeSafety: .safe, sortOrder: 5, plan: plan),
        ]
        return plan
    }

    // MARK: - Saturday or Sunday — Full Body Circuit + Cardio (50-55 min)

    private static func weekendPlan() -> WorkoutPlan {
        let plan = WorkoutPlan(
            name: "Full Body Circuit + Cardio",
            dayOfWeek: "Saturday or Sunday",
            duration: "50-55 min",
            focusArea: "Full Body + Cardiovascular Fitness",
            sortOrder: 3
        )
        plan.exercises = [
            Exercise(name: "Upright Bike",
                     detail: "Easy pace, get warm.",
                     sets: "5 min", type: .warmup, kneeSafety: .safe, sortOrder: 0, plan: plan),
            Exercise(name: "Smith Machine Squat",
                     detail: "Partial depth — stop at 90° knee.",
                     sets: "3 × 10", type: .circuit, kneeSafety: .caution, sortOrder: 1, plan: plan),
            Exercise(name: "Dumbbell Row",
                     detail: "One arm on bench. Pull to hip.",
                     sets: "3 × 10/arm", type: .circuit, kneeSafety: .safe, sortOrder: 2, plan: plan),
            Exercise(name: "Dumbbell Chest Fly",
                     detail: "Flat bench. Light weight, squeeze.",
                     sets: "3 × 12", type: .circuit, kneeSafety: .safe, sortOrder: 3, plan: plan),
            Exercise(name: "Hamstring Curl",
                     detail: "Lying or seated — whatever's open.",
                     sets: "3 × 12", type: .circuit, kneeSafety: .safe, sortOrder: 4, plan: plan),
            Exercise(name: "Shoulder Lateral Raise",
                     detail: "Light DBs. Don't go above shoulders.",
                     sets: "3 × 12", type: .circuit, kneeSafety: .safe, sortOrder: 5, plan: plan),
            Exercise(name: "Glute Bridge",
                     detail: "Floor. Dumbbell on hips if ready.",
                     sets: "3 × 15", type: .circuit, kneeSafety: .safe, sortOrder: 6, plan: plan),
            Exercise(name: "Cardio Finisher",
                     detail: "Upright bike or incline walk. Push it.",
                     sets: "15 min", type: .cardio, kneeSafety: .safe, sortOrder: 7, plan: plan),
        ]
        return plan
    }
}
