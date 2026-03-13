import SwiftUI
import SwiftData

/// Sheet for editing an existing exercise OR creating a custom exercise from scratch.
/// Also used as the "configure and add" step after picking from the Planet Fitness library.
///
/// Usage:
///   - Edit existing:   `EditExerciseView(plan: plan, exercise: existingExercise)`
///   - Custom new:      `EditExerciseView(plan: plan)`
///   - Library prefill: `EditExerciseView(plan: plan, prefill: pfExercise)`
struct EditExerciseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let plan: WorkoutPlan

    /// Existing exercise to edit. `nil` = creating a new one.
    var exercise: Exercise? = nil

    /// Planet Fitness library entry to pre-populate fields from.
    var prefill: PFExercise? = nil

    // MARK: - Form State

    @State private var name: String = ""
    @State private var detail: String = ""
    @State private var sets: String = ""
    @State private var type: ExerciseType = .strength
    @State private var kneeSafety: KneeSafety = .safe

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Name ──────────────────────────────────────────────────
                Section("Exercise Name") {
                    TextField("e.g. Lat Pulldown", text: $name)
                        .font(.system(size: 18))
                        .autocorrectionDisabled()
                }

                // ── Sets & Reps ───────────────────────────────────────────
                Section {
                    TextField("e.g. 3 × 10–12 reps", text: $sets)
                        .font(.system(size: 18).monospaced())
                        .autocorrectionDisabled()
                } header: {
                    Text("Sets & Reps")
                } footer: {
                    Text("Use any format: '3 x 12', '4 x 8-10 reps', '1 x 20 min', etc.")
                        .font(.system(size: 13))
                }

                // ── Form Cue ──────────────────────────────────────────────
                Section("Form Cue (optional)") {
                    TextField("Brief coaching note visible during workout", text: $detail, axis: .vertical)
                        .font(.system(size: 17))
                        .autocorrectionDisabled()
                        .lineLimit(3...6)
                }

                // ── Type ──────────────────────────────────────────────────
                Section("Exercise Type") {
                    Picker("Type", selection: $type) {
                        ForEach(ExerciseType.allCases, id: \.self) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }

                // ── Knee Safety ───────────────────────────────────────────
                Section {
                    ForEach(KneeSafety.allCases, id: \.self) { k in
                        Button {
                            kneeSafety = k
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: k.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(iconColor(k))
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(k.displayName)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(ColorTheme.primaryText)
                                    Text(kneeSafetyDescription(k))
                                        .font(.system(size: 14))
                                        .foregroundStyle(ColorTheme.secondaryText)
                                }

                                Spacer()

                                if kneeSafety == k {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(ColorTheme.blue)
                                }
                            }
                            .frame(minHeight: 52)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Knee Safety")
                } footer: {
                    Text("Caution exercises show an orange warning in the workout. Avoid = don't include.")
                        .font(.system(size: 13))
                }
            }
            .scrollContentBackground(.hidden)
            .background(ColorTheme.background)
            .navigationTitle(exercise == nil ? "Add Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.bold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { prefillFields() }
        }
    }

    // MARK: - Helpers

    private func prefillFields() {
        if let ex = exercise {
            name       = ex.name
            detail     = ex.detail
            sets       = ex.sets
            type       = ex.type
            kneeSafety = ex.kneeSafety
        } else if let pf = prefill {
            name       = pf.name
            detail     = pf.detail
            sets       = pf.defaultSets
            type       = pf.type
            kneeSafety = pf.kneeSafety
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let ex = exercise {
            ex.name       = trimmed
            ex.detail     = detail.trimmingCharacters(in: .whitespaces)
            ex.sets       = sets.trimmingCharacters(in: .whitespaces)
            ex.type       = type
            ex.kneeSafety = kneeSafety
        } else {
            let nextOrder = (plan.exercises.map(\.sortOrder).max() ?? 0) + 1
            let newEx = Exercise(
                name:       trimmed,
                detail:     detail.trimmingCharacters(in: .whitespaces),
                sets:       sets.trimmingCharacters(in: .whitespaces),
                type:       type,
                kneeSafety: kneeSafety,
                sortOrder:  nextOrder,
                plan:       plan
            )
            context.insert(newEx)
        }

        HapticManager.success()
        dismiss()
    }

    private func iconColor(_ k: KneeSafety) -> Color {
        switch k {
        case .safe:    return ColorTheme.green
        case .caution: return ColorTheme.orange
        case .avoid:   return ColorTheme.red
        }
    }

    private func kneeSafetyDescription(_ k: KneeSafety) -> String {
        switch k {
        case .safe:    return "No special concern for knees"
        case .caution: return "Modify weight / range if discomfort"
        case .avoid:   return "Skip this exercise on bad knee days"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutPlan.self, Exercise.self, configurations: config)
    let plan = WorkoutPlan(name: "Test", dayOfWeek: "Monday", duration: "45 min", focusArea: "Chest", sortOrder: 0)
    container.mainContext.insert(plan)
    return EditExerciseView(plan: plan)
        .modelContainer(container)
}
