import SwiftUI
import SwiftData

// MARK: - In-Memory Set Log

struct SetLog: Identifiable {
    let id = UUID()
    var reps: String = ""
    var weight: String = ""
    var isCompleted: Bool = false
}

// MARK: - WorkoutLogView

struct WorkoutLogView: View {
    let plan: WorkoutPlan

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var startTime = Date.now
    @State private var elapsedSeconds = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var logs: [UUID: [SetLog]] = [:]
    @State private var showSummary = false

    private var sortedExercises: [Exercise] {
        plan.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var completedSetCount: Int {
        logs.values.flatMap { $0 }.filter { $0.isCompleted }.count
    }

    private var totalSetCount: Int {
        logs.values.map { $0.count }.reduce(0, +)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sortedExercises) { exercise in
                    ExerciseSectionView(
                        exercise: exercise,
                        setLogs: Binding(
                            get: { logs[exercise.id] ?? [] },
                            set: { logs[exercise.id] = $0 }
                        )
                    )
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .background(ColorTheme.background)
        .navigationTitle(plan.dayOfWeek)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(plan.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ColorTheme.primaryText)
                    Text(elapsedString)
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(ColorTheme.blue)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .sheet(isPresented: $showSummary) {
            WorkoutSummaryView(
                plan: plan,
                elapsedSeconds: elapsedSeconds,
                logs: logs,
                exercises: sortedExercises,
                onSave: saveSession,
                onDiscard: { dismiss() }
            )
        }
        .onAppear {
            initLogs()
            startTimer()
        }
        .onDisappear {
            timerTask?.cancel()
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 8) {
                HStack {
                    Text("\(completedSetCount) of \(totalSetCount) sets done")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ColorTheme.secondaryText)
                    Spacer()
                    Text(elapsedString)
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundStyle(ColorTheme.blue)
                }
                LargeButton("Finish Workout", icon: "flag.checkered") {
                    HapticManager.medium()
                    timerTask?.cancel()
                    showSummary = true
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .background(.regularMaterial)
    }

    // MARK: - Helpers

    private var elapsedString: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func initLogs() {
        for exercise in sortedExercises {
            let count = setCount(for: exercise)
            logs[exercise.id] = (0..<count).map { _ in SetLog() }
        }
    }

    private func startTimer() {
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(1))
                    elapsedSeconds += 1
                } catch {
                    return
                }
            }
        }
    }

    private func setCount(for exercise: Exercise) -> Int {
        let s = exercise.sets
        guard s.contains("×") else { return 1 }
        let prefix = s.prefix(while: { $0.isNumber })
        return Int(prefix) ?? 3
    }

    private func saveSession() {
        let session = WorkoutSession(
            planName: plan.name,
            startTime: startTime,
            endTime: Date.now,
            isCompleted: true
        )
        context.insert(session)

        for exercise in sortedExercises {
            guard let setLogs = logs[exercise.id] else { continue }
            for (index, setLog) in setLogs.enumerated() {
                guard setLog.isCompleted else { continue }
                let log = ExerciseLog(
                    exerciseName: exercise.name,
                    setNumber: index + 1,
                    reps: Int(setLog.reps),
                    weight: Double(setLog.weight),
                    isCompleted: true,
                    session: session
                )
                context.insert(log)
            }
        }

        try? context.save()
        dismiss()
    }
}

// MARK: - ExerciseSectionView

struct ExerciseSectionView: View {
    let exercise: Exercise
    @Binding var setLogs: [SetLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(ColorTheme.primaryText)
                    Text(exercise.sets)
                        .font(.system(size: 15, weight: .semibold).monospaced())
                        .foregroundStyle(ColorTheme.blue)
                    if !exercise.detail.isEmpty {
                        Text(exercise.detail)
                            .font(.system(size: 14))
                            .foregroundStyle(
                                exercise.kneeSafety == .caution
                                    ? ColorTheme.orange
                                    : ColorTheme.secondaryText
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                KneeSafetyBadge(safety: exercise.kneeSafety)
            }

            // Column headers
            HStack(spacing: 0) {
                Text("SET")
                    .frame(width: 44, alignment: .leading)
                Text("LBS")
                    .frame(maxWidth: .infinity)
                Text("REPS")
                    .frame(maxWidth: .infinity)
                Spacer().frame(width: 56)
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(ColorTheme.secondaryText)
            .padding(.horizontal, 4)

            // Set rows
            ForEach(setLogs.indices, id: \.self) { i in
                SetEntryRow(setNumber: i + 1, log: $setLogs[i])
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    exercise.kneeSafety == .caution
                        ? ColorTheme.orange.opacity(0.3)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - SetEntryRow

struct SetEntryRow: View {
    let setNumber: Int
    @Binding var log: SetLog

    var body: some View {
        HStack(spacing: 8) {
            // Set number
            Text("\(setNumber)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(log.isCompleted ? ColorTheme.green : ColorTheme.secondaryText)
                .frame(width: 36, alignment: .leading)

            // Weight field
            TextField("—", text: $log.weight)
                .keyboardType(.decimalPad)
                .font(.system(size: 18, weight: .semibold).monospaced())
                .foregroundStyle(ColorTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(ColorTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Reps field
            TextField("0", text: $log.reps)
                .keyboardType(.numberPad)
                .font(.system(size: 18, weight: .semibold).monospaced())
                .foregroundStyle(ColorTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(ColorTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Done checkbox — 56pt gym-safe tap target
            Button {
                HapticManager.selection()
                log.isCompleted.toggle()
                if log.isCompleted { HapticManager.success() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(log.isCompleted ? ColorTheme.green : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    log.isCompleted ? ColorTheme.green : Color(UIColor.separator),
                                    lineWidth: 2
                                )
                        )
                        .frame(width: 40, height: 40)
                    if log.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - WorkoutSummaryView

struct WorkoutSummaryView: View {
    let plan: WorkoutPlan
    let elapsedSeconds: Int
    let logs: [UUID: [SetLog]]
    let exercises: [Exercise]
    let onSave: () -> Void
    let onDiscard: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var completedSets: Int {
        logs.values.flatMap { $0 }.filter { $0.isCompleted }.count
    }

    private var totalSets: Int {
        logs.values.map { $0.count }.reduce(0, +)
    }

    private var durationString: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return m > 0 ? "\(m) min \(s) sec" : "\(s) sec"
    }

    private var totalVolume: Double {
        logs.values.flatMap { $0 }
            .filter { $0.isCompleted }
            .compactMap { log -> Double? in
                guard let w = Double(log.weight), let r = Int(log.reps) else { return nil }
                return w * Double(r)
            }
            .reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(ColorTheme.orange)
                    .padding(.top, 24)

                Text("Workout Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)

                VStack(spacing: 12) {
                    statRow(
                        icon: "clock.fill",
                        label: "Duration",
                        value: durationString,
                        color: ColorTheme.blue
                    )
                    statRow(
                        icon: "checkmark.circle.fill",
                        label: "Sets Completed",
                        value: "\(completedSets) of \(totalSets)",
                        color: ColorTheme.green
                    )
                    if totalVolume > 0 {
                        statRow(
                            icon: "scalemass.fill",
                            label: "Total Volume",
                            value: String(format: "%.0f lbs", totalVolume),
                            color: ColorTheme.orange
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 12) {
                    LargeButton("Save Workout", icon: "square.and.arrow.down.fill", color: ColorTheme.green) {
                        HapticManager.success()
                        dismiss()
                        onSave()
                    }
                    Button("Discard Workout") {
                        HapticManager.soft()
                        dismiss()
                        onDiscard()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .frame(minHeight: 44)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(ColorTheme.background.ignoresSafeArea())
            .navigationTitle(plan.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func statRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 32)
            Text(label)
                .font(.system(size: 17))
                .foregroundStyle(ColorTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)
        }
        .padding(14)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
