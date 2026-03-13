import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let plan: WorkoutPlan

    @State private var checkedExercises: Set<UUID> = []
    @State private var showStartWorkout = false
    @State private var showRestTimer = false
    @State private var timerManager = RestTimerManager()

    private var sortedExercises: [Exercise] {
        plan.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var progress: Double {
        guard !sortedExercises.isEmpty else { return 0 }
        return Double(checkedExercises.count) / Double(sortedExercises.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                kneeReminderBanner
                progressBar
                exerciseList
            }
            .padding(.bottom, 100) // clearance for sticky bottom bar
        }
        .background(ColorTheme.background)
        .navigationTitle(plan.dayOfWeek)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationDestination(isPresented: $showStartWorkout) {
            WorkoutLogView(plan: plan)
        }
        .sheet(isPresented: $showRestTimer) {
            RestTimerView(manager: timerManager)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)

            Text(plan.focusArea)
                .font(.system(size: 17))
                .foregroundStyle(ColorTheme.secondaryText)

            HStack(spacing: 16) {
                Label(plan.duration, systemImage: "clock")
                Label("\(plan.exerciseCount) exercises", systemImage: "list.bullet")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(ColorTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Knee Reminder Banner

    private var kneeReminderBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(ColorTheme.orange)
                .font(.system(size: 18, weight: .semibold))

            Text("**Knee Rule:** If any exercise causes sharp pain, stop immediately. Dull soreness is OK — sharp or stabbing pain is not.")
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(ColorTheme.orange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ColorTheme.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(checkedExercises.count) of \(sortedExercises.count) complete")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ColorTheme.secondaryText)
                Spacer()
                if checkedExercises.count == sortedExercises.count && !sortedExercises.isEmpty {
                    Label("Done!", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ColorTheme.green)
                }
            }
            ProgressView(value: progress)
                .tint(progress == 1.0 ? ColorTheme.green : ColorTheme.blue)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        LazyVStack(spacing: 12) {
            ForEach(sortedExercises) { exercise in
                ExerciseCardView(
                    exercise: exercise,
                    isChecked: checkedExercises.contains(exercise.id),
                    onToggle: { toggle(exercise) }
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 10) {
                LargeButton("Start This Workout", icon: "play.fill") {
                    HapticManager.medium()
                    showStartWorkout = true
                }
                LargeButton("Rest Timer", icon: "timer", color: ColorTheme.secondaryText) {
                    HapticManager.soft()
                    showRestTimer = true
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(.regularMaterial)
    }

    // MARK: - Actions

    private func toggle(_ exercise: Exercise) {
        if checkedExercises.contains(exercise.id) {
            checkedExercises.remove(exercise.id)
            HapticManager.soft()
        } else {
            checkedExercises.insert(exercise.id)
            // Celebrate if all done
            if checkedExercises.count == sortedExercises.count {
                HapticManager.success()
            } else {
                HapticManager.selection()
            }
        }
    }
}
