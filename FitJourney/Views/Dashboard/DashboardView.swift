import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goalSettings: [GoalSettings]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Placeholder content — replaced in Step 8
                    placeholderCard(
                        icon: "scalemass.fill",
                        title: "Today's Weight",
                        subtitle: "Tap to log or connect Apple Health"
                    )
                    placeholderCard(
                        icon: "flame.fill",
                        title: "Calories",
                        subtitle: "Consumed vs. target"
                    )
                    placeholderCard(
                        icon: "figure.walk",
                        title: "Steps Today",
                        subtitle: "From Apple Health"
                    )
                    placeholderCard(
                        icon: "calendar",
                        title: "Next Workout",
                        subtitle: "Monday — Upper Body Strength"
                    )
                }
                .padding()
            }
            .background(ColorTheme.background)
            .navigationTitle("FitJourney")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func placeholderCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(ColorTheme.blue)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(ColorTheme.primaryText)
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(ColorTheme.secondaryText)
            }
            Spacer()
        }
        .padding(16)
        .background(ColorTheme.adaptiveCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: GoalSettings.self, inMemory: true)
}
