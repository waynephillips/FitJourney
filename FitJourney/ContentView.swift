import SwiftUI
import SwiftData

// Placeholder — will be replaced by MainTabView in Step 3
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPlan.sortOrder) private var plans: [WorkoutPlan]

    var body: some View {
        NavigationStack {
            List {
                if plans.isEmpty {
                    ContentUnavailableView("Loading…", systemImage: "figure.run")
                } else {
                    Section("Seeded Workout Plans (\(plans.count))") {
                        ForEach(plans) { plan in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plan.dayOfWeek)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(plan.name)
                                    .font(.headline)
                                Text("\(plan.exerciseCount) exercises · \(plan.duration)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("FitJourney")
        }
        .onAppear {
            WorkoutDataSeeder.seedIfNeeded(context: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WorkoutPlan.self, Exercise.self], inMemory: true)
}
