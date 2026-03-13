import SwiftUI
import SwiftData

// Placeholder — built out fully in Step 10
struct SettingsView: View {
    @Query private var goalSettings: [GoalSettings]

    var body: some View {
        NavigationStack {
            List {
                Section("Goal") {
                    settingsRow(icon: "target", label: "Target Weight", value: "180 lbs")
                    settingsRow(icon: "calendar", label: "Target Date", value: "Dec 31, 2026")
                    settingsRow(icon: "flame", label: "Daily Calories", value: "2,000 kcal")
                }

                Section("Health") {
                    settingsRow(icon: "heart.fill", label: "Apple Health", value: "Not connected")
                }

                Section("Display") {
                    settingsRow(icon: "textformat.size", label: "Text Size", value: "Large")
                    settingsRow(icon: "moon.fill", label: "Dark Mode", value: "System")
                }

                Section("About") {
                    settingsRow(icon: "info.circle", label: "Version", value: "1.0")

                    NavigationLink("Medical Disclaimer") {
                        disclaimerView
                    }
                    .font(.system(size: 18))
                    .frame(minHeight: 56)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func settingsRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(ColorTheme.blue)
                .frame(width: 28)
            Text(label)
                .font(.system(size: 18))
                .foregroundStyle(ColorTheme.primaryText)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundStyle(ColorTheme.secondaryText)
        }
        .frame(minHeight: 56)
    }

    private var disclaimerView: some View {
        ScrollView {
            Text("""
FitJourney is a fitness tracking tool and does not provide medical advice. This workout plan is general guidance, not a substitute for professional medical care. Please consult your doctor before beginning any new exercise program. If you experience sharp pain during any exercise, stop immediately and seek medical attention.
""")
            .font(.system(size: 18))
            .foregroundStyle(ColorTheme.primaryText)
            .lineSpacing(6)
            .padding()
        }
        .navigationTitle("Medical Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: GoalSettings.self, inMemory: true)
}
