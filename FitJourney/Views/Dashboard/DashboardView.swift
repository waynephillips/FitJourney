import SwiftUI
import SwiftData
import Charts

// MARK: - DashboardView

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthKitManager.self) private var healthKit

    @Query private var goalSettings: [GoalSettings]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \WorkoutPlan.sortOrder) private var plans: [WorkoutPlan]

    @State private var showLogWeight = false
    @State private var selectedPlan: WorkoutPlan?

    // MARK: - Goal Computed Values

    private var goal: GoalSettings?  { goalSettings.first }
    private var startWeight: Double  { goal?.startWeight  ?? 220 }
    private var targetWeight: Double { goal?.targetWeight ?? 180 }
    private var totalToLose: Double  { max(startWeight - targetWeight, 1) }
    private var currentWeight: Double { healthKit.latestWeightLbs ?? startWeight }
    private var lbsLost: Double  { max(startWeight - currentWeight, 0) }
    private var lbsToGo: Double  { max(currentWeight - targetWeight, 0) }
    private var progressFraction: Double { min(lbsLost / totalToLose, 1.0) }
    private var daysRemaining: Int { goal?.daysRemaining ?? 0 }

    // MARK: - Streak

    private var currentStreak: Int {
        let calendar = Calendar.current
        var checkDate = Date()

        // If no workout this week yet, start streak check from last week
        // so an in-progress streak isn't prematurely zeroed mid-week.
        if let thisWeek = calendar.dateInterval(of: .weekOfYear, for: checkDate) {
            let hasThisWeek = sessions.contains { $0.isCompleted && thisWeek.contains($0.date) }
            if !hasThisWeek {
                checkDate = thisWeek.start.addingTimeInterval(-1)
            }
        }

        var streak = 0
        for _ in 0..<52 {
            guard let week = calendar.dateInterval(of: .weekOfYear, for: checkDate) else { break }
            if sessions.contains(where: { $0.isCompleted && week.contains($0.date) }) {
                streak += 1
                checkDate = week.start.addingTimeInterval(-1)
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Next Workout

    private var nextWorkout: WorkoutPlan? {
        guard !plans.isEmpty else { return nil }
        let todayWD = Calendar.current.component(.weekday, from: Date()) // 1=Sun…7=Sat

        func weekday(for plan: WorkoutPlan) -> Int {
            switch plan.dayOfWeek {
            case "Monday":             return 2
            case "Thursday":           return 5
            case "Friday":             return 6
            case "Saturday or Sunday": return 7
            default:                   return 2
            }
        }

        func completedThisWeek(_ plan: WorkoutPlan) -> Bool {
            guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return false }
            return sessions.contains { $0.planName == plan.name && $0.isCompleted && week.contains($0.date) }
        }

        let sorted = plans.sorted {
            ((weekday(for: $0) - todayWD + 7) % 7) < ((weekday(for: $1) - todayWD + 7) % 7)
        }
        return sorted.first { !completedThisWeek($0) } ?? sorted.first
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingHeader
                    goalProgressCard
                    if healthKit.weightHistory.count > 1 {
                        weightChartCard
                    }
                    todayActivityRow
                    if let next = nextWorkout {
                        nextWorkoutCard(plan: next)
                    }
                    if currentStreak > 0 {
                        streakCard
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            .background(ColorTheme.background.ignoresSafeArea())
            .navigationTitle("FitJourney")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.soft()
                        showLogWeight = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(ColorTheme.blue)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityLabel("Log weight")
                }
            }
            .navigationDestination(item: $selectedPlan) { plan in
                WorkoutDetailView(plan: plan)
            }
            .sheet(isPresented: $showLogWeight) {
                LogWeightSheet()
                    .environment(healthKit)
            }
            .onAppear {
                Task { await healthKit.fetchAll() }
            }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ColorTheme.primaryText)
                Text(formattedDate)
                    .font(.system(size: 15))
                    .foregroundStyle(ColorTheme.secondaryText)
            }
            Spacer()
            if healthKit.authStatus == .authorized {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(ColorTheme.red)
                    .accessibilityLabel("Apple Health connected")
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning, Wayne!"
        case 12..<17: return "Good afternoon, Wayne!"
        default:      return "Good evening, Wayne!"
        }
    }

    private var formattedDate: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    // MARK: - Goal Progress Card

    private var goalProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("WEIGHT GOAL")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(ColorTheme.secondaryText)
                        .kerning(0.5)
                    Text("40-lb Journey")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(ColorTheme.primaryText)
                }
                Spacer()
                if let w = healthKit.latestWeightLbs {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.1f", w))
                            .font(.system(size: 28, weight: .bold).monospacedDigit())
                            .foregroundStyle(ColorTheme.blue)
                            .contentTransition(.numericText())
                            .animation(.default, value: w)
                        Text("lbs today")
                            .font(.system(size: 13))
                            .foregroundStyle(ColorTheme.secondaryText)
                    }
                } else {
                    Button {
                        HapticManager.soft()
                        showLogWeight = true
                    } label: {
                        Text("Log Weight")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(ColorTheme.blue)
                    }
                    .frame(minHeight: 44)
                }
            }

            // Gradient progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorTheme.blue.opacity(0.12))
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [ColorTheme.blue, ColorTheme.green],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: max(geo.size.width * progressFraction, 14), height: 14)
                        .animation(.easeInOut(duration: 0.6), value: progressFraction)
                }
            }
            .frame(height: 14)

            // Stats pills
            HStack(spacing: 10) {
                statPill(value: String(format: "%.1f", lbsLost),  label: "lbs lost",  color: ColorTheme.green)
                statPill(value: String(format: "%.1f", lbsToGo),  label: "to go",     color: ColorTheme.blue)
                statPill(value: "\(daysRemaining)",               label: "days left", color: ColorTheme.orange)
            }

            // Range labels
            HStack {
                Text(String(format: "%.0f lbs start", startWeight))
                Spacer()
                Text(String(format: "Goal: %.0f lbs", targetWeight))
            }
            .font(.system(size: 14))
            .foregroundStyle(ColorTheme.secondaryText)
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func statPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .animation(.default, value: value)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ColorTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Weight Chart Card

    private var weightChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weight Trend")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)
                Spacer()
                Text("90 days")
                    .font(.system(size: 14))
                    .foregroundStyle(ColorTheme.secondaryText)
            }

            Chart {
                RuleMark(y: .value("Goal", targetWeight))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundStyle(ColorTheme.green.opacity(0.7))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal \(Int(targetWeight)) lbs")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(ColorTheme.green)
                    }

                ForEach(healthKit.weightHistory) { point in
                    LineMark(
                        x: .value("Date", point.id),
                        y: .value("Weight", point.lbs)
                    )
                    .foregroundStyle(ColorTheme.blue)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.id),
                        y: .value("Weight", point.lbs)
                    )
                    .foregroundStyle(ColorTheme.blue)
                    .symbolSize(25)
                }
            }
            .chartYScale(domain: (targetWeight - 5)...(max(startWeight, currentWeight) + 3))
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { val in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = val.as(Double.self) {
                            Text("\(Int(v))")
                                .font(.system(size: 12))
                                .foregroundStyle(ColorTheme.secondaryText)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.system(size: 11))
                        .foregroundStyle(ColorTheme.secondaryText)
                }
            }
            .frame(height: 180)
            .accessibilityLabel("Weight trend chart for the last 90 days")
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - Today's Activity Row

    private var todayActivityRow: some View {
        HStack(spacing: 14) {
            activityCard(
                icon: "figure.walk",
                value: healthKit.todaySteps.formatted(),
                label: "STEPS",
                subtitle: "/ 10,000",
                color: ColorTheme.blue,
                progress: Double(healthKit.todaySteps) / 10_000
            )
            activityCard(
                icon: "flame.fill",
                value: "\(Int(healthKit.todayCalories))",
                label: "CALORIES",
                subtitle: goal.map { "/ \($0.dailyCalorieTarget)" } ?? "/ 2,000",
                color: ColorTheme.orange,
                progress: healthKit.todayCalories / Double(goal?.dailyCalorieTarget ?? 2000)
            )
        }
    }

    private func activityCard(
        icon: String,
        value: String,
        label: String,
        subtitle: String,
        color: Color,
        progress: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .kerning(0.4)
            }
            Text(value)
                .font(.system(size: 28, weight: .bold).monospacedDigit())
                .foregroundStyle(ColorTheme.primaryText)
                .contentTransition(.numericText())
                .animation(.default, value: value)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(ColorTheme.secondaryText)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * min(max(progress, 0), 1), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: - Next Workout Card

    private func nextWorkoutCard(plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("NEXT WORKOUT", systemImage: "dumbbell.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .kerning(0.4)
                Spacer()
                Text(plan.dayOfWeek)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ColorTheme.blue)
                    .clipShape(Capsule())
            }

            Text(plan.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)

            Text(plan.focusArea)
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.secondaryText)

            HStack(spacing: 18) {
                Label(plan.duration, systemImage: "clock")
                Label("\(plan.exerciseCount) exercises", systemImage: "list.bullet")
            }
            .font(.system(size: 15))
            .foregroundStyle(ColorTheme.secondaryText)

            Button {
                HapticManager.medium()
                selectedPlan = plan
            } label: {
                HStack {
                    Spacer()
                    Label("View Workout", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .frame(minHeight: 56)
                .background(ColorTheme.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ColorTheme.orange.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: "flame.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(ColorTheme.orange)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(currentStreak)")
                        .font(.system(size: 28, weight: .bold).monospacedDigit())
                        .foregroundStyle(ColorTheme.orange)
                        .contentTransition(.numericText())
                        .animation(.default, value: currentStreak)
                    Text(currentStreak == 1 ? "week" : "weeks")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ColorTheme.primaryText)
                }
                Text("Workout Streak")
                    .font(.system(size: 16))
                    .foregroundStyle(ColorTheme.secondaryText)
            }
            Spacer()
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

// MARK: - LogWeightSheet

struct LogWeightSheet: View {
    @Environment(HealthKitManager.self) private var healthKit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var weightText = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // Weight input
                VStack(spacing: 10) {
                    Text("Today's Weight")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(ColorTheme.secondaryText)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        TextField("0.0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 56, weight: .bold).monospacedDigit())
                            .foregroundStyle(ColorTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                            .frame(maxWidth: 220)
                        Text("lbs")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(ColorTheme.secondaryText)
                    }

                    if let current = healthKit.latestWeightLbs {
                        Text(String(format: "Last logged: %.1f lbs", current))
                            .font(.system(size: 16))
                            .foregroundStyle(ColorTheme.secondaryText)
                    }
                }

                if let err = errorMessage {
                    Text(err)
                        .font(.system(size: 15))
                        .foregroundStyle(ColorTheme.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    LargeButton(
                        isSaving ? "Saving…" : "Log Weight",
                        icon: "checkmark.circle.fill",
                        color: isValid ? ColorTheme.green : ColorTheme.secondaryText
                    ) {
                        guard isValid, !isSaving else { return }
                        HapticManager.medium()
                        Task { await save() }
                    }
                    .disabled(!isValid || isSaving)

                    Button("Cancel") {
                        HapticManager.soft()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .frame(minHeight: 44)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(ColorTheme.background.ignoresSafeArea())
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { isFocused = true }
        }
    }

    private var isValid: Bool {
        guard let v = Double(weightText) else { return false }
        return v > 50 && v < 700
    }

    private func save() async {
        guard let lbs = Double(weightText) else { return }
        isSaving = true
        errorMessage = nil

        do {
            try await healthKit.saveWeight(lbs)
        } catch {
            errorMessage = "Saved locally — HealthKit unavailable."
        }

        // Always persist in SwiftData
        let metric = BodyMetric(weight: lbs, source: "manual")
        modelContext.insert(metric)
        try? modelContext.save()

        HapticManager.success()
        isSaving = false
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .modelContainer(
            for: [GoalSettings.self, WorkoutSession.self,
                  WorkoutPlan.self, Exercise.self,
                  ExerciseLog.self, BodyMetric.self],
            inMemory: true
        )
        .environment(HealthKitManager())
}
