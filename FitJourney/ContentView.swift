import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MainTabView()
            .onAppear {
                WorkoutDataSeeder.seedIfNeeded(context: modelContext)
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [WorkoutPlan.self, Exercise.self, WorkoutSession.self,
                  ExerciseLog.self, BodyMetric.self, GoalSettings.self],
            inMemory: true
        )
}
