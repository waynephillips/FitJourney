import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard

    enum Tab: Int {
        case dashboard = 0
        case workouts  = 1
        case log       = 2
        case progress  = 3
        case settings  = 4
    }

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
                .tag(Tab.dashboard)

            WorkoutListView()
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }
                .tag(Tab.workouts)

            WorkoutLogView()
                .tabItem { Label("Log", systemImage: "plus.circle.fill") }
                .tag(Tab.log)

            FitProgressView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(Tab.progress)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(ColorTheme.blue)
    }

    // MARK: - Appearance

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        // Selected — bold blue, 13pt
        let selectedFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let selectedColor = UIColor(ColorTheme.blue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: selectedFont,
            .foregroundColor: selectedColor,
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor

        // Normal — medium gray, 13pt
        let normalFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let normalColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: normalFont,
            .foregroundColor: normalColor,
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor

        // Top separator — visible dividing line
        appearance.shadowColor = UIColor.separator

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .modelContainer(
            for: [WorkoutPlan.self, Exercise.self, WorkoutSession.self,
                  ExerciseLog.self, BodyMetric.self, GoalSettings.self],
            inMemory: true
        )
}
