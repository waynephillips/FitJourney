import SwiftUI

// Placeholder — will be replaced by MainTabView in Step 4
struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("FitJourney")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("Your 40-lb journey starts here.")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
