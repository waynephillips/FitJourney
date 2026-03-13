import SwiftUI

/// Coloured pill badge showing knee safety level for an exercise.
/// Safe = green, Caution = orange, Avoid = red — high contrast, always visible.
struct KneeSafetyBadge: View {
    let safety: KneeSafety

    var body: some View {
        Label(safety.displayName, systemImage: safety.icon)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch safety {
        case .safe:    return ColorTheme.green
        case .caution: return ColorTheme.orange
        case .avoid:   return ColorTheme.red
        }
    }

    private var background: Color {
        switch safety {
        case .safe:    return ColorTheme.green.opacity(0.14)
        case .caution: return ColorTheme.orange.opacity(0.14)
        case .avoid:   return ColorTheme.red.opacity(0.14)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        KneeSafetyBadge(safety: .safe)
        KneeSafetyBadge(safety: .caution)
        KneeSafetyBadge(safety: .avoid)
    }
    .padding()
}
