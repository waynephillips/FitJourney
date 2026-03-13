import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Query(sort: \WorkoutPlan.sortOrder) private var plans: [WorkoutPlan]
    @Query private var sessions: [WorkoutSession]
    @Environment(\.modelContext) private var context

    @State private var showNewWorkout = false
    @State private var planToEdit: WorkoutPlan? = nil
    @State private var planToDelete: WorkoutPlan? = nil

    var body: some View {
        NavigationStack {
            Group {
                if plans.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "dumbbell",
                        description: Text("Tap + to create your first workout plan.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(plans) { plan in
                                NavigationLink(destination: WorkoutDetailView(plan: plan)) {
                                    WorkoutPlanCard(
                                        plan: plan,
                                        completedThisWeek: isCompletedThisWeek(plan)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        planToEdit = plan
                                    } label: {
                                        Label("Edit Workout", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        planToDelete = plan
                                    } label: {
                                        Label("Delete Workout", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(ColorTheme.background)
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        HapticManager.selection()
                        showNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .accessibilityLabel("Create new workout")
                }
            }
            .sheet(isPresented: $showNewWorkout) {
                EditWorkoutView()
            }
            .sheet(item: $planToEdit) { plan in
                EditWorkoutView(plan: plan)
            }
            .alert(
                "Delete \"\(planToDelete?.name ?? "")\"?",
                isPresented: Binding(
                    get: { planToDelete != nil },
                    set: { if !$0 { planToDelete = nil } }
                )
            ) {
                Button("Delete", role: .destructive) {
                    if let plan = planToDelete {
                        context.delete(plan)
                        HapticManager.medium()
                    }
                    planToDelete = nil
                }
                Button("Cancel", role: .cancel) { planToDelete = nil }
            } message: {
                Text("All exercises in this plan will also be removed. This cannot be undone.")
            }
        }
    }

    private func isCompletedThisWeek(_ plan: WorkoutPlan) -> Bool {
        let startOfWeek = Calendar.current
            .dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return sessions.contains {
            $0.planName == plan.name && $0.isCompleted && $0.date >= startOfWeek
        }
    }
}

// MARK: - Plan Card

struct WorkoutPlanCard: View {
    let plan: WorkoutPlan
    let completedThisWeek: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day + completion badge
            HStack(alignment: .firstTextBaseline) {
                Text(plan.dayOfWeek.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ColorTheme.blue)
                Spacer()
                if completedThisWeek {
                    Label("Done this week", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ColorTheme.green)
                }
            }

            // Name + focus
            Text(plan.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)
                .multilineTextAlignment(.leading)

            if !plan.focusArea.isEmpty {
                Text(plan.focusArea)
                    .font(.system(size: 16))
                    .foregroundStyle(ColorTheme.secondaryText)
            }

            Divider()

            // Stats row
            HStack(spacing: 0) {
                statItem(icon: "list.bullet", label: "\(plan.exerciseCount) exercises")
                Spacer()
                statItem(icon: "clock", label: plan.duration)
                Spacer()
                if plan.hasCautionExercises {
                    statItem(icon: "exclamationmark.triangle.fill",
                             label: "Knee caution",
                             color: ColorTheme.orange)
                } else {
                    statItem(icon: "checkmark.circle.fill",
                             label: "Knee safe",
                             color: ColorTheme.green)
                }
            }
        }
        .padding(18)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    completedThisWeek
                        ? ColorTheme.green.opacity(0.45)
                        : Color(UIColor.separator).opacity(0.5),
                    lineWidth: completedThisWeek ? 2 : 1
                )
        )
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private func statItem(icon: String, label: String, color: Color = ColorTheme.secondaryText) -> some View {
        Label(label, systemImage: icon)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(color)
    }
}

#Preview {
    WorkoutListView()
        .modelContainer(for: [WorkoutPlan.self, Exercise.self, WorkoutSession.self], inMemory: true)
}
