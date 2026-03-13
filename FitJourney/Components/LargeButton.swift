import SwiftUI

/// Full-width button with 56pt minimum height — designed for gym use with sweaty hands.
struct LargeButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = ColorTheme.blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        LargeButton("Start Workout", icon: "play.fill") {}
        LargeButton("Complete Set", icon: "checkmark", color: ColorTheme.green) {}
        LargeButton("Skip Exercise", color: .gray) {}
    }
    .padding()
}
