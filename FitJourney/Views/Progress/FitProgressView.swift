import SwiftUI
import SwiftData

// Named FitProgressView to avoid conflict with SwiftUI's built-in ProgressView.
// Built out fully in Step 9.
struct FitProgressView: View {
    @Query(sort: \BodyMetric.date, order: .reverse) private var metrics: [BodyMetric]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(ColorTheme.blue)

                Text("Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ColorTheme.primaryText)

                Text("Your weight trend, milestone history, and workout streaks will appear here.")
                    .font(.system(size: 18))
                    .foregroundStyle(ColorTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if !metrics.isEmpty {
                    Text("\(metrics.count) weight entries recorded")
                        .font(.system(size: 16))
                        .foregroundStyle(ColorTheme.green)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ColorTheme.background)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    FitProgressView()
        .modelContainer(for: BodyMetric.self, inMemory: true)
}
