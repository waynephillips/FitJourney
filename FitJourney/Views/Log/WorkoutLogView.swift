import SwiftUI

// Placeholder — built out fully in Step 6
struct WorkoutLogView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(ColorTheme.blue)

                Text("Log a Workout")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)

                Text("Select a workout plan to begin logging your sets, reps, and weights.")
                    .font(.system(size: 18))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ColorTheme.background)
            .navigationTitle("Log")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    WorkoutLogView()
}
