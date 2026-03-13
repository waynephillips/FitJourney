import SwiftUI
import SwiftData

/// Sheet for creating a new workout plan or editing an existing plan's metadata
/// (name, day of week, estimated duration, focus area description).
struct EditWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WorkoutPlan.sortOrder) private var allPlans: [WorkoutPlan]

    /// Pass `nil` to create a new plan; pass an existing plan to edit it.
    var plan: WorkoutPlan? = nil

    // MARK: - Form State

    @State private var name: String = ""
    @State private var dayOfWeek: String = "Monday"
    @State private var duration: String = "45–50 min"
    @State private var focusArea: String = ""

    // MARK: - Constants

    private let days = [
        "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday", "Sunday", "Any Day"
    ]
    private let durations = [
        "20–30 min", "30–40 min", "40–45 min",
        "45–50 min", "50–60 min", "60–75 min", "75–90 min"
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Name ──────────────────────────────────────────────────
                Section {
                    TextField("e.g. Upper Body Strength", text: $name)
                        .font(.system(size: 18))
                        .autocorrectionDisabled()
                } header: {
                    Text("Workout Name")
                }

                // ── Day ───────────────────────────────────────────────────
                Section {
                    Picker("Day", selection: $dayOfWeek) {
                        ForEach(days, id: \.self) { day in
                            Text(day).tag(day)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 140)
                } header: {
                    Text("Day of Week")
                } footer: {
                    Text("Choose 'Any Day' if this workout isn't tied to a specific day.")
                        .font(.system(size: 13))
                }

                // ── Duration ──────────────────────────────────────────────
                Section {
                    Picker("Duration", selection: $duration) {
                        ForEach(durations, id: \.self) { d in
                            Text(d).tag(d)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 140)
                } header: {
                    Text("Estimated Duration")
                }

                // ── Focus Area ────────────────────────────────────────────
                Section {
                    TextField("e.g. Chest, Back & Biceps", text: $focusArea, axis: .vertical)
                        .font(.system(size: 18))
                        .autocorrectionDisabled()
                        .lineLimit(2...4)
                } header: {
                    Text("Focus Area (optional)")
                } footer: {
                    Text("Shown as a subtitle on the workout card.")
                        .font(.system(size: 13))
                }
            }
            .scrollContentBackground(.hidden)
            .background(ColorTheme.background)
            .navigationTitle(plan == nil ? "New Workout" : "Edit Workout")
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
            .onAppear { prefillIfEditing() }
        }
    }

    // MARK: - Helpers

    private func prefillIfEditing() {
        guard let plan else { return }
        name       = plan.name
        dayOfWeek  = plan.dayOfWeek
        duration   = plan.duration
        focusArea  = plan.focusArea
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let plan {
            // Update existing
            plan.name      = trimmedName
            plan.dayOfWeek = dayOfWeek
            plan.duration  = duration
            plan.focusArea = focusArea.trimmingCharacters(in: .whitespaces)
        } else {
            // Create new — append after all existing plans
            let nextOrder = (allPlans.map(\.sortOrder).max() ?? 0) + 1
            let newPlan = WorkoutPlan(
                name:      trimmedName,
                dayOfWeek: dayOfWeek,
                duration:  duration,
                focusArea: focusArea.trimmingCharacters(in: .whitespaces),
                sortOrder: nextOrder
            )
            context.insert(newPlan)
        }

        HapticManager.success()
        dismiss()
    }
}

#Preview {
    EditWorkoutView()
        .modelContainer(for: [WorkoutPlan.self, Exercise.self], inMemory: true)
}
