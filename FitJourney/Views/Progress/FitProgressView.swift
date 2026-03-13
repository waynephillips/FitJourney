import SwiftUI
import SwiftData
import Charts

// Named FitProgressView to avoid conflict with SwiftUI's built-in ProgressView.

// MARK: - FitProgressView

struct FitProgressView: View {
    @Environment(HealthKitManager.self) private var healthKit

    @Query private var goalSettings: [GoalSettings]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \BodyMetric.date, order: .reverse) private var metrics: [BodyMetric]

    @State private var selectedTab = 0   // 0=Weight, 1=Workouts
    @State private var weightDays  = 90  // 30 | 90 | 180

    // MARK: - Goal helpers

    private var goal: GoalSettings?  { goalSettings.first }
    private var startWeight: Double  { goal?.startWeight  ?? 220 }
    private var targetWeight: Double { goal?.targetWeight ?? 180 }
    private var currentWeight: Double { healthKit.latestWeightLbs ?? startWeight }
    private var lbsLost: Double  { max(startWeight - currentWeight, 0) }
    private var lbsToGo: Double  { max(currentWeight - targetWeight, 0) }

    // MARK: - Weight chart data

    private var filteredHistory: [WeightDataPoint] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -weightDays, to: Date()) ?? Date()
        return healthKit.weightHistory.filter { $0.id >= cutoff }
    }

    // MARK: - Milestones (every 5 lbs)

    private let milestones: [Double] = [5, 10, 15, 20, 25, 30, 35, 40]

    // MARK: - Workout stats

    private var completedSessions: [WorkoutSession] {
        sessions.filter { $0.isCompleted }
    }

    private var totalMinutes: Int {
        completedSessions.map { $0.durationMinutes }.reduce(0, +)
    }

    private var totalVolumeLbs: Double {
        completedSessions.map { $0.totalVolume }.reduce(0, +)
    }

    private var volumeString: String {
        totalVolumeLbs >= 1000
            ? String(format: "%.1fK", totalVolumeLbs / 1000)
            : String(format: "%.0f", totalVolumeLbs)
    }

    // MARK: - Weekly consistency (last 12 weeks)

    private struct WeekBar: Identifiable {
        let id: Date
        let count: Int
    }

    private var weeklyBars: [WeekBar] {
        let calendar = Calendar.current
        return (0..<12).reversed().compactMap { ago -> WeekBar? in
            guard
                let anchor   = calendar.date(byAdding: .weekOfYear, value: -ago, to: Date()),
                let interval = calendar.dateInterval(of: .weekOfYear, for: anchor)
            else { return nil }
            let count = completedSessions.filter { interval.contains($0.date) }.count
            return WeekBar(id: interval.start, count: count)
        }
    }

    private var recentSessions: [WorkoutSession] {
        Array(completedSessions.prefix(8))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Picker("", selection: $selectedTab) {
                    Text("Weight").tag(0)
                    Text("Workouts").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(ColorTheme.background)

                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            weightSection
                        } else {
                            workoutsSection
                        }
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
                .background(ColorTheme.background.ignoresSafeArea())
            }
            .background(ColorTheme.background.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { Task { await healthKit.fetchAll() } }
        }
    }

    // MARK: - Weight Section

    @ViewBuilder
    private var weightSection: some View {
        weightHeroCard
        weightChartCard
        milestonesCard
    }

    private var weightHeroCard: some View {
        HStack(spacing: 0) {
            weightCell(value: String(format: "%.1f", currentWeight), unit: "lbs",
                       label: "Current", color: ColorTheme.blue)
            Divider().frame(height: 56)
            weightCell(value: String(format: "%.1f", lbsLost), unit: "lbs",
                       label: "Lost", color: ColorTheme.green)
            Divider().frame(height: 56)
            weightCell(value: String(format: "%.1f", lbsToGo), unit: "lbs",
                       label: "To Go", color: ColorTheme.orange)
            Divider().frame(height: 56)
            weightCell(value: String(format: "%.0f", targetWeight), unit: "lbs",
                       label: "Goal", color: ColorTheme.secondaryText)
        }
        .padding(.vertical, 14)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func weightCell(value: String, unit: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold).monospacedDigit())
                    .foregroundStyle(color)
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(color.opacity(0.7))
            }
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ColorTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var weightChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Weight History")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)
                Spacer()
                Picker("Range", selection: $weightDays) {
                    Text("1M").tag(30)
                    Text("3M").tag(90)
                    Text("6M").tag(180)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }

            if filteredHistory.count < 2 {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(ColorTheme.secondaryText.opacity(0.5))
                    Text("Log your weight to see a trend")
                        .font(.system(size: 16))
                        .foregroundStyle(ColorTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
            } else {
                Chart {
                    RuleMark(y: .value("Goal", targetWeight))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .foregroundStyle(ColorTheme.green.opacity(0.65))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Goal \(Int(targetWeight)) lbs")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(ColorTheme.green)
                        }

                    ForEach(filteredHistory) { point in
                        AreaMark(
                            x: .value("Date", point.id),
                            yStart: .value("Base", targetWeight - 5),
                            yEnd: .value("Weight", point.lbs)
                        )
                        .foregroundStyle(LinearGradient(
                            colors: [ColorTheme.blue.opacity(0.18), ColorTheme.blue.opacity(0.02)],
                            startPoint: .top, endPoint: .bottom
                        ))
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Date", point.id),
                            y: .value("Weight", point.lbs)
                        )
                        .foregroundStyle(ColorTheme.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", point.id),
                            y: .value("Weight", point.lbs)
                        )
                        .foregroundStyle(ColorTheme.blue)
                        .symbolSize(18)
                    }
                }
                .chartYScale(domain: (targetWeight - 5)...(max(startWeight, currentWeight) + 3))
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { val in
                        AxisGridLine().foregroundStyle(Color(UIColor.separator).opacity(0.5))
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
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine().foregroundStyle(Color(UIColor.separator).opacity(0.3))
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .font(.system(size: 11))
                            .foregroundStyle(ColorTheme.secondaryText)
                    }
                }
                .frame(height: 220)
                .accessibilityLabel("Weight history chart")
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private var milestonesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)

            Text(String(format: "%.1f lbs lost toward your 40-lb goal", lbsLost))
                .font(.system(size: 15))
                .foregroundStyle(ColorTheme.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(milestones, id: \.self) { milestone in
                        let unlocked = lbsLost >= milestone
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(unlocked
                                          ? ColorTheme.green.opacity(0.15)
                                          : Color(UIColor.systemFill))
                                    .frame(width: 54, height: 54)
                                Image(systemName: unlocked ? "checkmark.seal.fill" : "seal")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(unlocked ? ColorTheme.green : ColorTheme.secondaryText)
                            }
                            Text("-\(Int(milestone))")
                                .font(.system(size: 15, weight: .bold).monospacedDigit())
                                .foregroundStyle(unlocked ? ColorTheme.green : ColorTheme.secondaryText)
                            Text("lbs")
                                .font(.system(size: 12))
                                .foregroundStyle(ColorTheme.secondaryText)
                        }
                        .frame(width: 68)
                        .opacity(unlocked ? 1.0 : 0.55)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - Workouts Section

    @ViewBuilder
    private var workoutsSection: some View {
        workoutStatsRow
        weeklyConsistencyCard
        if recentSessions.isEmpty {
            emptyWorkoutsCard
        } else {
            recentSessionsCard
        }
    }

    private var workoutStatsRow: some View {
        HStack(spacing: 12) {
            workoutStatTile(value: "\(completedSessions.count)",
                            label: "Sessions",   icon: "dumbbell.fill",   color: ColorTheme.blue)
            workoutStatTile(value: "\(totalMinutes)",
                            label: "Minutes",    icon: "clock.fill",      color: ColorTheme.orange)
            workoutStatTile(value: volumeString,
                            label: "Lbs Lifted", icon: "scalemass.fill",  color: ColorTheme.green)
        }
    }

    private func workoutStatTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold).monospacedDigit())
                .foregroundStyle(ColorTheme.primaryText)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ColorTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var weeklyConsistencyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weekly Consistency")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)
                Spacer()
                Text("12 weeks")
                    .font(.system(size: 14))
                    .foregroundStyle(ColorTheme.secondaryText)
            }

            if weeklyBars.allSatisfy({ $0.count == 0 }) {
                Text("Complete workouts to see your consistency trend.")
                    .font(.system(size: 15))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 100)
            } else {
                Chart(weeklyBars) { bar in
                    BarMark(
                        x: .value("Week", bar.id, unit: .weekOfYear),
                        y: .value("Sessions", bar.count)
                    )
                    .foregroundStyle(
                        bar.count >= 2 ? ColorTheme.green
                        : bar.count == 1 ? ColorTheme.blue
                        : Color(UIColor.systemFill)
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                            .font(.system(size: 10))
                            .foregroundStyle(ColorTheme.secondaryText)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 1, 2, 3]) { val in
                        AxisGridLine().foregroundStyle(Color(UIColor.separator).opacity(0.4))
                        AxisValueLabel {
                            if let v = val.as(Int.self) {
                                Text("\(v)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(ColorTheme.secondaryText)
                            }
                        }
                    }
                }
                .frame(height: 130)
                .accessibilityLabel("Weekly workout consistency bar chart, last 12 weeks")

                HStack(spacing: 16) {
                    legendItem(color: ColorTheme.green,          label: "2+ sessions")
                    legendItem(color: ColorTheme.blue,           label: "1 session")
                    legendItem(color: Color(UIColor.systemFill), label: "Rest week")
                }
                .font(.system(size: 12))
                .foregroundStyle(ColorTheme.secondaryText)
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
        }
    }

    private var recentSessionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Workouts")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)

            VStack(spacing: 0) {
                ForEach(recentSessions) { session in
                    sessionRow(session)
                    if session.id != recentSessions.last?.id {
                        Divider().padding(.leading, 54)
                    }
                }
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ColorTheme.blue.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ColorTheme.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.planName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTheme.primaryText)
                Text(session.date.formatted(
                    .dateTime.weekday(.abbreviated).month(.abbreviated).day()
                ))
                .font(.system(size: 14))
                .foregroundStyle(ColorTheme.secondaryText)
            }

            Spacer()

            if session.durationMinutes > 0 {
                Text("\(session.durationMinutes) min")
                    .font(.system(size: 14, weight: .semibold).monospacedDigit())
                    .foregroundStyle(ColorTheme.orange)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(ColorTheme.orange.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    private var emptyWorkoutsCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 48))
                .foregroundStyle(ColorTheme.secondaryText.opacity(0.6))
            Text("No workouts yet")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)
            Text("Complete your first workout to start tracking progress here.")
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Preview

#Preview {
    FitProgressView()
        .modelContainer(
            for: [GoalSettings.self, WorkoutSession.self,
                  ExerciseLog.self, BodyMetric.self],
            inMemory: true
        )
        .environment(HealthKitManager())
}
