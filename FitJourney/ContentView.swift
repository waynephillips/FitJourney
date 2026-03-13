import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthKitManager.self) private var healthKit

    var body: some View {
        MainTabView()
            .onAppear {
                WorkoutDataSeeder.seedIfNeeded(context: modelContext)
                Task { await healthKit.requestAuthorization() }
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
