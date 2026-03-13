import SwiftUI

// MARK: - RestTimerManager

@Observable @MainActor
final class RestTimerManager {
    var totalSeconds: Int = 90
    var remainingSeconds: Int = 90
    var isRunning: Bool = false
    var hasCompleted: Bool = false

    private var timerTask: Task<Void, Never>?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var ringColor: Color {
        if remainingSeconds <= 10 { return ColorTheme.red }
        if remainingSeconds <= 30 { return ColorTheme.orange }
        return ColorTheme.blue
    }

    func select(duration: Int) {
        pause()
        totalSeconds = duration
        remainingSeconds = duration
        hasCompleted = false
    }

    func start() {
        guard !isRunning, remainingSeconds > 0 else { return }
        isRunning = true
        hasCompleted = false
        timerTask = Task { @MainActor in
            await runLoop()
        }
    }

    func pause() {
        timerTask?.cancel()
        timerTask = nil
        isRunning = false
    }

    func reset() {
        pause()
        remainingSeconds = totalSeconds
        hasCompleted = false
    }

    private func runLoop() async {
        while remainingSeconds > 0 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return // Task cancelled
            }
            remainingSeconds -= 1
            if remainingSeconds == 10 {
                HapticManager.warning()
            }
        }
        // Finished
        isRunning = false
        hasCompleted = true
        HapticManager.success()
    }
}

// MARK: - RestTimerView

struct RestTimerView: View {
    @Bindable var manager: RestTimerManager

    private let presets = [60, 90, 120]

    var body: some View {
        VStack(spacing: 32) {
            // Title
            Text("Rest Timer")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(ColorTheme.primaryText)
                .padding(.top, 8)

            // Ring + countdown
            ZStack {
                // Track
                Circle()
                    .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 10)
                    .frame(width: 220, height: 220)

                // Progress arc
                Circle()
                    .trim(from: 0, to: manager.progress)
                    .stroke(
                        manager.ringColor,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: manager.progress)

                // Countdown
                VStack(spacing: 4) {
                    Text(manager.timeString)
                        .font(.system(size: 56, weight: .bold).monospacedDigit())
                        .foregroundStyle(ColorTheme.primaryText)
                        .contentTransition(.numericText())

                    if manager.hasCompleted {
                        Text("Rest complete!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ColorTheme.green)
                    }
                }
            }

            // Preset buttons
            HStack(spacing: 12) {
                ForEach(presets, id: \.self) { seconds in
                    Button {
                        HapticManager.selection()
                        manager.select(duration: seconds)
                    } label: {
                        Text(seconds == 60 ? "1 min" : seconds == 90 ? "90 s" : "2 min")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(
                                manager.totalSeconds == seconds
                                    ? .white
                                    : ColorTheme.blue
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                manager.totalSeconds == seconds
                                    ? ColorTheme.blue
                                    : ColorTheme.blue.opacity(0.10)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Play/Pause + Reset
            HStack(spacing: 24) {
                // Reset
                Button {
                    HapticManager.soft()
                    manager.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(ColorTheme.secondaryText)
                        .frame(width: 64, height: 64)
                        .background(Color(UIColor.separator).opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Play / Pause
                Button {
                    if manager.isRunning {
                        HapticManager.soft()
                        manager.pause()
                    } else {
                        HapticManager.medium()
                        if manager.hasCompleted { manager.reset() }
                        manager.start()
                    }
                } label: {
                    Image(systemName: manager.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(ColorTheme.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: manager.isRunning)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(ColorTheme.background.ignoresSafeArea())
    }
}

#Preview {
    RestTimerView(manager: RestTimerManager())
}
