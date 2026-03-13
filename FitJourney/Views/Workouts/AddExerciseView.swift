import SwiftUI
import SwiftData

/// Browseable Planet Fitness exercise library.
/// Tap any exercise to configure sets/reps and add it to the plan.
/// Tap "Custom" in the toolbar to create a completely custom exercise.
struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss

    let plan: WorkoutPlan

    // MARK: - State

    @State private var searchText = ""
    @State private var selectedCategory: PFExercise.ExerciseCategory? = nil
    @State private var selectedPFExercise: PFExercise? = nil
    @State private var showCustomForm = false

    // MARK: - Filtered data

    private var filteredExercises: [PFExercise] {
        var list = PlanetFitnessExerciseLibrary.all
        if let cat = selectedCategory {
            list = list.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.detail.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    private var groupedExercises: [(PFExercise.ExerciseCategory, [PFExercise])] {
        let cats = selectedCategory.map { [$0] } ?? PFExercise.ExerciseCategory.allCases
        return cats.compactMap { cat in
            let exs = filteredExercises.filter { $0.category == cat }
            return exs.isEmpty ? nil : (cat, exs)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Category chips ─────────────────────────────────────────
                categoryFilterBar
                    .padding(.vertical, 10)
                    .background(ColorTheme.background)

                Divider()

                // ── Exercise list ──────────────────────────────────────────
                if filteredExercises.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(groupedExercises, id: \.0) { (category, exercises) in
                            Section {
                                ForEach(exercises) { pf in
                                    LibraryExerciseRow(pf: pf) {
                                        HapticManager.selection()
                                        selectedPFExercise = pf
                                    }
                                }
                            } header: {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue.uppercased())
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(ColorTheme.blue)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(ColorTheme.background)
                }
            }
            .background(ColorTheme.background)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search \(PlanetFitnessExerciseLibrary.all.count) exercises…"
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        HapticManager.selection()
                        showCustomForm = true
                    } label: {
                        Label("Custom Exercise", systemImage: "square.and.pencil")
                    }
                    .accessibilityLabel("Create custom exercise")
                }
            }
            // Tapped a library entry → configure & add
            .sheet(item: $selectedPFExercise) { pf in
                EditExerciseView(plan: plan, prefill: pf)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            // Toolbar "Custom" button
            .sheet(isPresented: $showCustomForm) {
                EditExerciseView(plan: plan)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Category Filter Bar

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryFilterChip(
                    label: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                    }
                }

                ForEach(PFExercise.ExerciseCategory.allCases, id: \.self) { cat in
                    CategoryFilterChip(
                        label: cat.rawValue,
                        icon: cat.icon,
                        isSelected: selectedCategory == cat
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(ColorTheme.secondaryText.opacity(0.5))
            Text("No exercises found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ColorTheme.primaryText)
            Text("Try a different search term or create a custom exercise.")
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                showCustomForm = true
            } label: {
                Label("Create Custom Exercise", systemImage: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ColorTheme.blue)
            }
            Spacer()
        }
    }
}

// MARK: - Category Filter Chip

private struct CategoryFilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
            }
            .foregroundStyle(isSelected ? .white : ColorTheme.primaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? ColorTheme.blue : ColorTheme.adaptiveCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(UIColor.separator), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

// MARK: - Library Exercise Row

private struct LibraryExerciseRow: View {
    let pf: PFExercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(pf.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ColorTheme.primaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        Text(pf.defaultSets)
                            .font(.system(size: 13).monospaced())
                            .foregroundStyle(ColorTheme.blue)

                        KneeSafetyBadge(safety: pf.kneeSafety)
                    }
                }

                Spacer(minLength: 12)

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(ColorTheme.blue)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minHeight: 56)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutPlan.self, Exercise.self, configurations: config)
    let plan = WorkoutPlan(name: "Upper Body", dayOfWeek: "Monday", duration: "45 min", focusArea: "Chest & Back", sortOrder: 0)
    container.mainContext.insert(plan)
    return AddExerciseView(plan: plan)
        .modelContainer(container)
}
