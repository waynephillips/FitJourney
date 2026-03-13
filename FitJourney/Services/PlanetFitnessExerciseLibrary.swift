import Foundation

// MARK: - PFExercise

/// A single exercise entry from the Planet Fitness equipment library.
struct PFExercise: Identifiable {
    var id: String { name }
    let name: String
    let detail: String          // coaching / form cue
    let defaultSets: String     // suggested sets / reps string
    let type: ExerciseType
    let kneeSafety: KneeSafety
    let category: ExerciseCategory

    enum ExerciseCategory: String, CaseIterable, Hashable {
        case warmup    = "Warm-Up"
        case chest     = "Chest"
        case back      = "Back"
        case shoulders = "Shoulders"
        case arms      = "Arms"
        case legs      = "Legs"
        case core      = "Core"
        case cardio    = "Cardio"

        var icon: String {
            switch self {
            case .warmup:    return "figure.walk"
            case .chest:     return "figure.strengthtraining.traditional"
            case .back:      return "figure.rowing"
            case .shoulders: return "figure.arms.open"
            case .arms:      return "dumbbell.fill"
            case .legs:      return "figure.run"
            case .core:      return "figure.core.training"
            case .cardio:    return "heart.fill"
            }
        }
    }
}

// MARK: - Library

enum PlanetFitnessExerciseLibrary {

    static let all: [PFExercise] =
        warmup + chest + back + shoulders + arms + legs + core + cardio

    // MARK: Warm-Up

    static let warmup: [PFExercise] = [
        PFExercise(
            name: "Treadmill Walk (Warm-Up)",
            detail: "5 min at 2–3 mph, arms swinging naturally. No holding rails.",
            defaultSets: "1 × 5 min",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Stationary Bike (Warm-Up)",
            detail: "Easy pace, seat at hip height, light resistance. Legs should never fully lock.",
            defaultSets: "1 × 5 min",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Elliptical (Warm-Up)",
            detail: "Low resistance, smooth full-stride motion. Use arm poles for full-body warm-up.",
            defaultSets: "1 × 5 min",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Arm Circles",
            detail: "10 forward, 10 backward — gradually increase range of motion each set.",
            defaultSets: "2 × 20 reps",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Hip Circles",
            detail: "Hands on hips, large slow circles each direction. Loosen hip flexors.",
            defaultSets: "2 × 10 each side",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Leg Swings",
            detail: "Hold cable machine for balance, swing leg forward and back. Progressively larger arc.",
            defaultSets: "2 × 10 each leg",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Cat-Cow Stretch",
            detail: "On mat — arch back on inhale (cow), round on exhale (cat). Move with breath.",
            defaultSets: "1 × 10 reps",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Band Pull-Aparts",
            detail: "Hold band at shoulder width, pull apart squeezing shoulder blades. Great rotator cuff activation.",
            defaultSets: "2 × 15 reps",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Shoulder Rolls",
            detail: "Roll shoulders backward in large circles, then forward. Releases upper trap tension.",
            defaultSets: "2 × 10 each direction",
            type: .warmup, kneeSafety: .safe, category: .warmup),
        PFExercise(
            name: "Glute Bridge (Warm-Up)",
            detail: "Lie on mat, feet flat, drive hips up squeezing glutes — activates posterior chain.",
            defaultSets: "2 × 15 reps",
            type: .warmup, kneeSafety: .safe, category: .warmup),
    ]

    // MARK: Chest

    static let chest: [PFExercise] = [
        PFExercise(
            name: "Machine Chest Press",
            detail: "Set seat so handles are at mid-chest. Full extension without locking elbows at top.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Pec Deck / Chest Fly Machine",
            detail: "Slight elbow bend throughout; pause and squeeze at peak contraction. Don't slam plates.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Cable Chest Fly (High-to-Low)",
            detail: "Set cables high, pull down and together in an arc — targets lower/inner chest. Keep core tight.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Cable Chest Fly (Low-to-High)",
            detail: "Set cables at ankle height, pull up and together — targets upper/inner chest.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Dumbbell Bench Press",
            detail: "Lower until elbows are just below chest level (45° from body). Press explosively.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Incline Dumbbell Press",
            detail: "Bench at 30–45°. Lower dumbbells to upper chest, press straight up. Targets upper chest.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Dumbbell Chest Fly",
            detail: "Slight elbow bend, wide arc down to 90° — stop immediately if any shoulder discomfort.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Push-Up",
            detail: "Hands shoulder-width, body in rigid plank. Modify to knees if needed — no ego here.",
            defaultSets: "3 × max reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Smith Machine Bench Press",
            detail: "Bar touches lower chest; use safety catches. Elbows at 45°, controlled descent.",
            defaultSets: "3 × 8–10 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
        PFExercise(
            name: "Cable Crossover",
            detail: "Arms slightly bent, sweep from wide to cross at center — full chest squeeze at peak.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .chest),
    ]

    // MARK: Back

    static let back: [PFExercise] = [
        PFExercise(
            name: "Lat Pulldown (Cable)",
            detail: "Wide overhand grip, lean back slightly, pull bar to upper chest — squeeze lats hard.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Seated Cable Row",
            detail: "Neutral grip, row to lower chest keeping elbows tucked. Pause 1 sec at full contraction.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Machine Seated Row",
            detail: "Chest against pad, pull handles to sides squeezing shoulder blades together.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Cable Straight-Arm Pulldown",
            detail: "Arms straight, hinge at shoulder pulling bar to thighs — isolates the lats.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Dumbbell Single-Arm Row",
            detail: "Brace on bench, pull elbow straight to ceiling. Weight travels straight up, not back.",
            defaultSets: "3 × 10–12 each side",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Cable Face Pull",
            detail: "Rope at face height, pull to forehead with external rotation — essential for shoulder health.",
            defaultSets: "3 × 15 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Back Extension Machine",
            detail: "Cross arms on chest, hinge forward, extend back to neutral — NOT hyperextended.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Assisted Pull-Up Machine",
            detail: "Counterweight assists; full range of motion. Pause 1 sec at top, lower slowly.",
            defaultSets: "3 × 8–10 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Dumbbell Romanian Deadlift",
            detail: "Hip hinge with soft knee bend — push hips back until hamstring stretch, not lower back stress.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .caution, category: .back),
        PFExercise(
            name: "Close-Grip Lat Pulldown",
            detail: "Neutral grip attachment, pull to upper chest — emphasizes lower lats and biceps.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .back),
        PFExercise(
            name: "Reverse Grip Pulldown",
            detail: "Underhand grip, elbows drive down to sides — great lat and bicep combo movement.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .back),
    ]

    // MARK: Shoulders

    static let shoulders: [PFExercise] = [
        PFExercise(
            name: "Machine Shoulder Press",
            detail: "Seat so handles start at ear height; press overhead without arching lower back.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Dumbbell Overhead Press",
            detail: "Press straight overhead, slight forward lean; lower controlled to ear level.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Dumbbell Lateral Raise",
            detail: "Slight elbow bend, raise to just below shoulder height — no shrugging or momentum.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Cable Lateral Raise",
            detail: "Cable at ankle height, cross-body pull up to shoulder level — constant tension throughout.",
            defaultSets: "3 × 12–15 each side",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Dumbbell Front Raise",
            detail: "Alternate arms, raise to shoulder height with control — don't swing.",
            defaultSets: "3 × 12 each arm",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Dumbbell Rear Delt Fly",
            detail: "Hinge forward 45°, raise elbows out to sides with slight bend — squeeze rear delts.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Arnold Press",
            detail: "Start with palms facing you, rotate out as you press overhead — works all three delt heads.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Cable Upright Row",
            detail: "Pull to chin, elbows flare above hands — stop at chin level to protect shoulder joint.",
            defaultSets: "3 × 12 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Cable Rear Delt Fly",
            detail: "Set both cables to chest height, cross handles. Open arms wide — excellent rear delt isolation.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
        PFExercise(
            name: "Machine Reverse Fly",
            detail: "Chest against pad, arms wide — drive elbows back squeezing rear delts and upper back.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .shoulders),
    ]

    // MARK: Arms

    static let arms: [PFExercise] = [
        // Biceps
        PFExercise(
            name: "Dumbbell Bicep Curl",
            detail: "Full supination at top; lower fully before next rep. Zero momentum — elbows stay pinned.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Cable Bicep Curl",
            detail: "Constant tension throughout full range; elbows stay pinned at sides.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "EZ Bar Preacher Curl",
            detail: "Chest against pad, curl to chin. Full extension at bottom — feel the stretch.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Hammer Curl (Dumbbell)",
            detail: "Neutral grip (thumbs up), curl straight up. Works brachialis for arm thickness.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Preacher Curl Machine",
            detail: "Pad supports upper arm; full range of motion. 2-second negative on the way down.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Concentration Curl (Dumbbell)",
            detail: "Seated, elbow braced on inner thigh. Curl to shoulder — zero body sway allowed.",
            defaultSets: "3 × 10 each arm",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Incline Dumbbell Curl",
            detail: "Recline bench to 45–60°; arms hang straight — maximizes bicep stretch at bottom.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        // Triceps
        PFExercise(
            name: "Cable Tricep Pushdown (Rope)",
            detail: "Elbows locked at sides; extend fully spreading rope at bottom — feel the squeeze.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Cable Tricep Pushdown (Bar)",
            detail: "Overhand grip, elbows fixed at sides. Full extension and pause at bottom.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Overhead Cable Tricep Extension",
            detail: "Face away from cable, arms overhead — full stretch at bottom, explosive squeeze at top.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Dumbbell Skull Crusher",
            detail: "Lying on flat bench, lower dumbbells to temples — elbows stay pointed at ceiling.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Tricep Kickback (Dumbbell)",
            detail: "Hinge forward, upper arm parallel to floor. Extend arm fully and hold 1 sec.",
            defaultSets: "3 × 12 each arm",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Assisted Dip Machine",
            detail: "Counterweight assists. Lower until 90° at elbow, press fully. Chest forward = chest focus.",
            defaultSets: "3 × 8–10 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
        PFExercise(
            name: "Close-Grip Machine Chest Press",
            detail: "Narrow grip on chest press machine shifts emphasis to triceps over chest.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .arms),
    ]

    // MARK: Legs

    static let legs: [PFExercise] = [
        PFExercise(
            name: "Leg Press Machine",
            detail: "Feet shoulder-width at mid-plate. Lower until 90° at knee — never lock out at top. Keep lower back flat on pad.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .caution, category: .legs),
        PFExercise(
            name: "Seated Leg Curl Machine",
            detail: "Pad just above Achilles; curl fully, hold 1 sec at peak, lower slowly. Easiest on knees.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Lying Leg Curl Machine",
            detail: "Hip against pad, curl heel toward glute — don't lift hips off bench.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Leg Extension Machine",
            detail: "Use light weight; extend only to 80–90° — avoid full lockout to reduce patellar stress.",
            defaultSets: "3 × 12–15 reps",
            type: .strength, kneeSafety: .caution, category: .legs),
        PFExercise(
            name: "Hip Abductor Machine",
            detail: "Press knees outward against pads; slow and controlled — great for glutes and IT band stability.",
            defaultSets: "3 × 15 reps",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Hip Adductor Machine",
            detail: "Squeeze knees together from wide position; pause at midline. Inner thigh focus.",
            defaultSets: "3 × 15 reps",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Seated Calf Raise Machine",
            detail: "Full range of motion; pause 1 sec at top and 1 sec at bottom for maximum growth.",
            defaultSets: "3 × 15–20 reps",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Standing Calf Raise (Machine)",
            detail: "Shoulders under pads; full stretch at bottom, full extension at top. Slow negative.",
            defaultSets: "3 × 15–20 reps",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Glute Kickback Machine",
            detail: "Press pad back and up with heel; squeeze glute at top and hold 1 sec. Keep hips square.",
            defaultSets: "3 × 12–15 each leg",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Cable Hip Extension",
            detail: "Ankle cuff, stand facing cable stack — kick leg back and up isolating glute.",
            defaultSets: "3 × 12–15 each leg",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Cable Hip Abduction",
            detail: "Ankle cuff, stand sideways to cable — sweep leg out to the side for glute med and TFL.",
            defaultSets: "3 × 15 each leg",
            type: .strength, kneeSafety: .safe, category: .legs),
        PFExercise(
            name: "Hack Squat Machine",
            detail: "Heels slightly elevated; squat only as deep as comfortable. Stop immediately at any knee pain.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .caution, category: .legs),
        PFExercise(
            name: "Smith Machine Squat",
            detail: "Feet slightly forward of bar; squat to parallel with controlled descent. Stop at any knee pain.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .caution, category: .legs),
        PFExercise(
            name: "Dumbbell Romanian Deadlift",
            detail: "Soft knee bend, push hips back — hamstrings control the descent, not lower back.",
            defaultSets: "3 × 10–12 reps",
            type: .strength, kneeSafety: .caution, category: .legs),
        PFExercise(
            name: "Dumbbell Step-Up",
            detail: "Use a low step (6–8 in). Drive through heel to stand, keep knee tracking over toes.",
            defaultSets: "3 × 10 each leg",
            type: .strength, kneeSafety: .caution, category: .legs),
        PFExercise(
            name: "Wall Sit",
            detail: "Back flat on wall, thighs parallel to floor — hold position and breathe normally.",
            defaultSets: "3 × 30–60 sec",
            type: .strength, kneeSafety: .caution, category: .legs),
    ]

    // MARK: Core

    static let core: [PFExercise] = [
        PFExercise(
            name: "Ab Crunch Machine",
            detail: "Slow and controlled; exhale hard at peak contraction — avoid pulling with neck.",
            defaultSets: "3 × 15–20 reps",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Cable Crunch",
            detail: "Kneel, rope at neck; crunch elbows toward knees — hips must stay still.",
            defaultSets: "3 × 15–20 reps",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Torso Rotation Machine",
            detail: "Rotate through abs, NOT hips — keep hips pinned to seat throughout.",
            defaultSets: "3 × 15 each side",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Plank",
            detail: "Elbows under shoulders, body in rigid line. Breathe normally. No sagging hips.",
            defaultSets: "3 × 30–60 sec",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Side Plank",
            detail: "Stack feet or stagger; hold body in rigid line. Modify with knee down if needed.",
            defaultSets: "3 × 20–30 sec each side",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Bicycle Crunch",
            detail: "Slow and deliberate — bring opposite elbow to knee with full torso rotation.",
            defaultSets: "3 × 20 reps",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Lying Leg Raise",
            detail: "Legs straight, lower to just above mat — lower back stays pressed flat.",
            defaultSets: "3 × 12–15 reps",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Russian Twist (Dumbbell)",
            detail: "Feet off ground, lean back 45°, rotate dumbbell side to side — slow and controlled.",
            defaultSets: "3 × 20 reps",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Dead Bug",
            detail: "Lower back pressed to mat; alternate opposite arm and leg — slow and deliberate.",
            defaultSets: "3 × 10 each side",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Bird Dog",
            detail: "On all fours — extend opposite arm and leg, hold 2 sec, return with full control.",
            defaultSets: "3 × 10 each side",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Mountain Climber",
            detail: "Plank position, drive knees to chest alternating quickly — hips stay level.",
            defaultSets: "3 × 30 sec",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Hollow Body Hold",
            detail: "Lie flat, arms overhead — lift shoulders and legs slightly, hold the tension. Lower back flat.",
            defaultSets: "3 × 20–30 sec",
            type: .core, kneeSafety: .safe, category: .core),
        PFExercise(
            name: "Ab Wheel Rollout",
            detail: "Kneel, roll out until almost flat, pull back with core — never let lower back sag.",
            defaultSets: "3 × 8–10 reps",
            type: .core, kneeSafety: .safe, category: .core),
    ]

    // MARK: Cardio

    static let cardio: [PFExercise] = [
        PFExercise(
            name: "Treadmill Walk",
            detail: "Brisk pace 3–4 mph, incline 2–5%. No holding rails — let arms swing naturally.",
            defaultSets: "1 × 20–30 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
        PFExercise(
            name: "Treadmill Incline Walk",
            detail: "Set incline to 10–15%, pace 2.5–3 mph — high calorie burn with minimal knee impact.",
            defaultSets: "1 × 20–30 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
        PFExercise(
            name: "Treadmill Jog",
            detail: "Comfortable conversational pace; land mid-foot with slight forward lean.",
            defaultSets: "1 × 15–25 min",
            type: .cardio, kneeSafety: .caution, category: .cardio),
        PFExercise(
            name: "HIIT Treadmill Intervals",
            detail: "1 min fast walk/jog / 2 min easy walk alternating — excellent fat burn with lower joint stress.",
            defaultSets: "8–10 intervals",
            type: .cardio, kneeSafety: .caution, category: .cardio),
        PFExercise(
            name: "Elliptical Trainer",
            detail: "Low impact; use arm poles for full-body cardio. Keep resistance challenging but sustainable.",
            defaultSets: "1 × 20–30 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
        PFExercise(
            name: "Stationary Bike",
            detail: "Seat at hip height; slight knee bend at bottom of pedal stroke. Lowest knee stress of all cardio.",
            defaultSets: "1 × 20–30 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
        PFExercise(
            name: "Recumbent Bike",
            detail: "Back supported, legs extended forward — most comfortable, ideal on high knee-pain days.",
            defaultSets: "1 × 20–30 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
        PFExercise(
            name: "Stair Climber",
            detail: "Hands lightly on rails for balance only; full step with whole foot — no tiptoe stepping.",
            defaultSets: "1 × 15–20 min",
            type: .cardio, kneeSafety: .caution, category: .cardio),
        PFExercise(
            name: "Rowing Machine",
            detail: "Drive with legs first, lean back, then pull arms to lower chest — reverse order on return.",
            defaultSets: "1 × 15–20 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
        PFExercise(
            name: "Arc Trainer",
            detail: "Cross-trainer style; low joint stress and high calorie burn — adjust stride depth for comfort.",
            defaultSets: "1 × 20–30 min",
            type: .cardio, kneeSafety: .safe, category: .cardio),
    ]
}
