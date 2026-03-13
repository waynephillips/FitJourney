import SwiftUI
import SwiftData

// Placeholder — built out fully in Step 4
struct WorkoutListView: View {
    @Query(sort: \WorkoutPlan.sortOrder) private var plans: [WorkoutPlan]

    var body: some View {
        NavigationStack {
            List {
                if plans.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "dumbbell",
                        description: Text("Workout plans will appear here.")
                    )
                } else {
                    ForEach(plans) { plan in
                        workoutRow(plan)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func workoutRow(_ plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(plan.dayOfWeek)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ColorTheme.blue)
                    .textCase(.uppercase)
                Spacer()
                Text(plan.duration)
                    .font(.system(size: 14))
                    .foregroundStyle(ColorTheme.secondaryText)
            }
            Text(plan.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)
            Text(plan.focusArea)
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.secondaryText)
            Text("\(plan.exerciseCount) exercises")
                .font(.system(size: 15))
                .foregroundStyle(ColorTheme.secondaryText)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 56)
    }
}

#Preview {
    WorkoutListView()
        .modelContainer(for: [WorkoutPlan.self, Exercise.self], inMemory: true)
}
