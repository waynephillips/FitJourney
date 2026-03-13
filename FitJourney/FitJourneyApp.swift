import SwiftUI
import SwiftData

@main
struct FitJourneyApp: App {

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GoalSettings.self,
            WorkoutPlan.self,
            Exercise.self,
            WorkoutSession.self,
            ExerciseLog.self,
            BodyMetric.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
