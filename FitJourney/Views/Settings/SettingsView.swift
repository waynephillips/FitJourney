import SwiftUI
import SwiftData
import HealthKit

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthKitManager.self) private var healthKit

    @Query private var goalSettings: [GoalSettings]

    @State private var showResetHistoryAlert = false
    @State private var showResetGoalAlert    = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            List {

                // ── GOAL ────────────────────────────────────────────────
                if let goal = goalSettings.first {
                    GoalSettingsSection(goal: goal)
                } else {
                    Section("Goal") {
                        Button("Set Up Your Goal") { seedGoal() }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(ColorTheme.blue)
                            .frame(minHeight: 56)
                    }
                }

                // ── HEALTH ──────────────────────────────────────────────
                Section {
                    healthKitRow
                } header: {
                    sectionHeader("Apple Health")
                }

                // ── DATA ────────────────────────────────────────────────
                Section {
                    Button(role: .destructive) {
                        showResetHistoryAlert = true
                    } label: {
                        settingLabel(icon: "trash",
                                     text: "Reset Workout History",
                                     iconColor: ColorTheme.red)
                    }
                    .frame(minHeight: 56)

                    Button(role: .destructive) {
                        showResetGoalAlert = true
                    } label: {
                        settingLabel(icon: "arrow.counterclockwise",
                                     text: "Reset Goal to Defaults",
                                     iconColor: ColorTheme.orange)
                    }
                    .frame(minHeight: 56)
                } header: {
                    sectionHeader("Data")
                }

                // ── ABOUT ───────────────────────────────────────────────
                Section {
                    HStack {
                        settingLabel(icon: "app.badge", text: "Version", iconColor: ColorTheme.blue)
                        Spacer()
                        Text(appVersion)
                            .font(.system(size: 16))
                            .foregroundStyle(ColorTheme.secondaryText)
                    }
                    .frame(minHeight: 56)

                    NavigationLink {
                        MedicalDisclaimerView()
                    } label: {
                        settingLabel(icon: "cross.case.fill",
                                     text: "Medical Disclaimer",
                                     iconColor: ColorTheme.red)
                    }
                    .frame(minHeight: 56)

                    NavigationLink {
                        KneeSafetyInfoView()
                    } label: {
                        settingLabel(icon: "figure.walk",
                                     text: "Knee Safety Guide",
                                     iconColor: ColorTheme.orange)
                    }
                    .frame(minHeight: 56)
                } header: {
                    sectionHeader("About")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(ColorTheme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { seedGoalIfNeeded() }
            .alert("Reset Workout History?", isPresented: $showResetHistoryAlert) {
                Button("Delete All", role: .destructive) { resetWorkoutHistory() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This permanently deletes all logged workout sessions. Your workout plans are kept. This cannot be undone.")
            }
            .alert("Reset Goal to Defaults?", isPresented: $showResetGoalAlert) {
                Button("Reset", role: .destructive) { resetGoal() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This resets your goal settings to the defaults: 220 → 180 lbs by Dec 31, 2026.")
            }
        }
    }

    // MARK: - HealthKit row

    @ViewBuilder
    private var healthKitRow: some View {
        switch healthKit.authStatus {
        case .authorized:
            HStack(spacing: 14) {
                iconBox(systemName: "heart.fill", color: ColorTheme.red)
                Text("Apple Health Connected")
                    .font(.system(size: 18))
                    .foregroundStyle(ColorTheme.primaryText)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(ColorTheme.green)
            }
            .frame(minHeight: 56)

        case .denied:
            HStack(spacing: 14) {
                iconBox(systemName: "heart.slash.fill", color: ColorTheme.red)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Access Denied")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ColorTheme.primaryText)
                    Text("Enable in iPhone Settings → Privacy → Health")
                        .font(.system(size: 14))
                        .foregroundStyle(ColorTheme.secondaryText)
                }
                Spacer()
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ColorTheme.orange)
            }
            .frame(minHeight: 64)

        default:  // .notDetermined
            HStack(spacing: 14) {
                iconBox(systemName: "heart.fill", color: ColorTheme.red)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Apple Health")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ColorTheme.primaryText)
                    Text("Sync weight, steps, and calories")
                        .font(.system(size: 14))
                        .foregroundStyle(ColorTheme.secondaryText)
                }
                Spacer()
                Button("Connect") {
                    Task { await healthKit.requestAuthorization() }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ColorTheme.blue)
                .clipShape(Capsule())
            }
            .frame(minHeight: 64)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(ColorTheme.secondaryText)
            .textCase(.uppercase)
    }

    private func settingLabel(icon: String, text: String, iconColor: Color) -> some View {
        HStack(spacing: 14) {
            iconBox(systemName: icon, color: iconColor)
            Text(text)
                .font(.system(size: 18))
                .foregroundStyle(ColorTheme.primaryText)
        }
    }

    private func iconBox(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    // MARK: - Data actions

    private func seedGoalIfNeeded() {
        guard goalSettings.isEmpty else { return }
        seedGoal()
    }

    private func seedGoal() {
        // Remove any existing (shouldn't happen, but defensive)
        goalSettings.forEach { modelContext.delete($0) }
        modelContext.insert(GoalSettings())
        try? modelContext.save()
    }

    private func resetWorkoutHistory() {
        let descriptor = FetchDescriptor<WorkoutSession>()
        if let sessions = try? modelContext.fetch(descriptor) {
            sessions.forEach { modelContext.delete($0) }
            try? modelContext.save()
        }
        HapticManager.medium()
    }

    private func resetGoal() {
        goalSettings.forEach { modelContext.delete($0) }
        modelContext.insert(GoalSettings())
        try? modelContext.save()
        HapticManager.medium()
    }
}

// MARK: - GoalSettingsSection
// Broken out so @Bindable can be applied to the SwiftData model.

private struct GoalSettingsSection: View {
    @Bindable var goal: GoalSettings

    var body: some View {
        Section {
            // Start weight
            weightStepper(
                label: "Starting Weight",
                icon: "scalemass",
                value: $goal.startWeight,
                range: 100...400,
                step: 0.5,
                format: "%.1f lbs"
            )

            // Target weight
            weightStepper(
                label: "Target Weight",
                icon: "target",
                value: $goal.targetWeight,
                range: 80...380,
                step: 0.5,
                format: "%.1f lbs"
            )

            // Target date
            DatePicker(selection: $goal.targetDate, displayedComponents: .date) {
                HStack(spacing: 14) {
                    iconBox(systemName: "calendar", color: ColorTheme.blue)
                    Text("Target Date")
                        .font(.system(size: 18))
                        .foregroundStyle(ColorTheme.primaryText)
                }
            }
            .frame(minHeight: 56)

            // Weekly goal
            intStepper(
                label: "Weekly Goal",
                icon: "chart.line.downtrend.xyaxis",
                displayValue: String(format: "%.2g lbs/wk", goal.weeklyGoalLbs),
                onDecrement: { goal.weeklyGoalLbs = max(0.25, goal.weeklyGoalLbs - 0.25) },
                onIncrement: { goal.weeklyGoalLbs = min(2.0,  goal.weeklyGoalLbs + 0.25) }
            )

            // Daily calories
            intStepper(
                label: "Daily Calories",
                icon: "flame",
                displayValue: "\(goal.dailyCalorieTarget) kcal",
                onDecrement: { goal.dailyCalorieTarget = max(1200, goal.dailyCalorieTarget - 50) },
                onIncrement: { goal.dailyCalorieTarget = min(4000, goal.dailyCalorieTarget + 50) }
            )

            // Protein target
            intStepper(
                label: "Protein Target",
                icon: "bolt.fill",
                displayValue: "\(goal.proteinTargetGrams) g",
                onDecrement: { goal.proteinTargetGrams = max(50,  goal.proteinTargetGrams - 5) },
                onIncrement: { goal.proteinTargetGrams = min(300, goal.proteinTargetGrams + 5) }
            )

        } header: {
            Text("Goal")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ColorTheme.secondaryText)
                .textCase(.uppercase)
        } footer: {
            Text("Aim for 0.5–1.0 lbs/week for sustainable, healthy weight loss.")
                .font(.system(size: 14))
                .foregroundStyle(ColorTheme.secondaryText)
        }
    }

    // Continuous double stepper (e.g. weight)
    private func weightStepper(
        label: String,
        icon: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        format: String
    ) -> some View {
        HStack(spacing: 12) {
            iconBox(systemName: icon, color: ColorTheme.blue)
            Text(label)
                .font(.system(size: 18))
                .foregroundStyle(ColorTheme.primaryText)
            Spacer()
            // Custom +/- with large tap targets
            stepperControls(
                displayValue: String(format: format, value.wrappedValue),
                onDecrement: {
                    if value.wrappedValue - step >= range.lowerBound {
                        value.wrappedValue -= step
                    }
                },
                onIncrement: {
                    if value.wrappedValue + step <= range.upperBound {
                        value.wrappedValue += step
                    }
                }
            )
        }
        .frame(minHeight: 56)
    }

    // Integer / custom-step stepper
    private func intStepper(
        label: String,
        icon: String,
        displayValue: String,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            iconBox(systemName: icon, color: ColorTheme.blue)
            Text(label)
                .font(.system(size: 18))
                .foregroundStyle(ColorTheme.primaryText)
            Spacer()
            stepperControls(
                displayValue: displayValue,
                onDecrement: onDecrement,
                onIncrement: onIncrement
            )
        }
        .frame(minHeight: 56)
    }

    private func stepperControls(
        displayValue: String,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 2) {
            Button {
                HapticManager.soft()
                onDecrement()
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTheme.blue)
                    .frame(width: 36, height: 36)
                    .background(ColorTheme.blue.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(width: 44, height: 44)

            Text(displayValue)
                .font(.system(size: 16, weight: .semibold).monospacedDigit())
                .foregroundStyle(ColorTheme.primaryText)
                .frame(minWidth: 80, alignment: .center)

            Button {
                HapticManager.soft()
                onIncrement()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTheme.blue)
                    .frame(width: 36, height: 36)
                    .background(ColorTheme.blue.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(width: 44, height: 44)
        }
    }

    private func iconBox(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - MedicalDisclaimerView

private struct MedicalDisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                disclaimerBlock(
                    icon: "cross.case.fill",
                    color: ColorTheme.red,
                    title: "Not Medical Advice",
                    body: "FitJourney is a fitness tracking tool and does not provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional before starting any new exercise or nutrition program."
                )
                disclaimerBlock(
                    icon: "exclamationmark.triangle.fill",
                    color: ColorTheme.orange,
                    title: "Stop If You Feel Pain",
                    body: "If you experience sharp, sudden, or worsening pain during any exercise — especially in your knees, joints, or chest — stop immediately and seek medical attention."
                )
                disclaimerBlock(
                    icon: "figure.walk",
                    color: ColorTheme.blue,
                    title: "Knee Safety",
                    body: "Exercises marked with a caution indicator require careful attention to form and range of motion. The 'avoid' list reflects common guidance for individuals with knee concerns, but your specific situation may differ. Consult a physical therapist for personalized guidance."
                )
                disclaimerBlock(
                    icon: "heart.text.square.fill",
                    color: ColorTheme.green,
                    title: "Individual Results Vary",
                    body: "Weight loss and fitness results depend on many factors including genetics, diet, sleep, and consistency. The plans and calorie targets in this app are starting points, not guarantees."
                )
            }
            .padding()
        }
        .background(ColorTheme.background.ignoresSafeArea())
        .navigationTitle("Medical Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func disclaimerBlock(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)
                Text(body)
                    .font(.system(size: 16))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - KneeSafetyInfoView

private struct KneeSafetyInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                infoCard(
                    badge: "SAFE", badgeColor: ColorTheme.green,
                    title: "Green — Safe for Knees",
                    body: "These exercises are low-impact and generally safe for individuals with knee concerns. Focus on controlled movement and proper form."
                )
                infoCard(
                    badge: "CAUTION", badgeColor: ColorTheme.orange,
                    title: "Orange — Use Caution",
                    body: "These exercises place moderate stress on the knees. Use the lightest weight that challenges you, stay above 90° knee bend, and stop if you feel any sharp pain."
                )
                infoCard(
                    badge: "AVOID", badgeColor: ColorTheme.red,
                    title: "Red — Avoid",
                    body: "These exercises involve deep knee flexion or high impact that can aggravate knee conditions. They have been excluded from your workout plans."
                )

                Text("Knee Tips During Workouts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 10) {
                    tipRow("Always warm up with 5 minutes of light cardio before lifting.")
                    tipRow("On Leg Press: never let knees travel past your toes.")
                    tipRow("On all squatting movements: keep knees tracking over your toes.")
                    tipRow("If a knee feels warm or swollen, take an extra rest day.")
                    tipRow("Ice sore knees for 15 min after workouts when needed.")
                }
            }
            .padding()
        }
        .background(ColorTheme.background.ignoresSafeArea())
        .navigationTitle("Knee Safety Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoCard(badge: String, badgeColor: Color, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(badge)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .clipShape(Capsule())
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)
            }
            Text(body)
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(ColorTheme.green)
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.primaryText)
                .lineSpacing(3)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(for: GoalSettings.self, inMemory: true)
        .environment(HealthKitManager())
}
