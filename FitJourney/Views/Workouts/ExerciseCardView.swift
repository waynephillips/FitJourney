import SwiftUI

/// Full exercise card with name, sets/reps, form cue, knee-safety badge, and 56pt checkbox.
/// Designed for readability at arm's length in the gym.
struct ExerciseCardView: View {
    let exercise: Exercise
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Badges row
                HStack(spacing: 8) {
                    typePill
                    KneeSafetyBadge(safety: exercise.kneeSafety)
                }

                // Exercise name
                Text(exercise.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isChecked ? ColorTheme.secondaryText : ColorTheme.primaryText)
                    .strikethrough(isChecked, color: ColorTheme.secondaryText)

                // Sets / reps — monospaced so numbers align
                Text(exercise.sets)
                    .font(.system(size: 18, weight: .semibold).monospaced())
                    .foregroundStyle(isChecked ? ColorTheme.secondaryText.opacity(0.7) : ColorTheme.blue)

                // Form cue
                if !exercise.detail.isEmpty {
                    Text(exercise.detail)
                        .font(.system(size: 16, weight: exercise.kneeSafety == .caution ? .semibold : .regular))
                        .foregroundStyle(exercise.kneeSafety == .caution ? ColorTheme.orange : ColorTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 12)

            // Checkbox — 56×56pt tap target (gym-safe)
            Button(action: {
                HapticManager.selection()
                onToggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isChecked ? ColorTheme.green : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isChecked ? ColorTheme.green : Color(UIColor.separator), lineWidth: 2)
                        )
                        .frame(width: 40, height: 40)

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 56, height: 56) // full tap area
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isChecked
                ? "Mark \(exercise.name) as incomplete"
                : "Mark \(exercise.name) as complete")
            .accessibilityAddTraits(.isButton)
        }
        .padding(16)
        .background(
            isChecked
                ? ColorTheme.adaptiveCard.opacity(0.55)
                : ColorTheme.adaptiveCard
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isChecked)
    }

    // MARK: - Sub-views

    private var typePill: some View {
        Text(exercise.type.displayName.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(ColorTheme.secondaryText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(ColorTheme.background)
            .clipShape(Capsule())
    }

    private var borderColor: Color {
        guard !isChecked else { return Color.clear }
        switch exercise.kneeSafety {
        case .safe:    return Color.clear
        case .caution: return ColorTheme.orange.opacity(0.35)
        case .avoid:   return ColorTheme.red.opacity(0.35)
        }
    }
}
