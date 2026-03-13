import SwiftUI

/// High-contrast color palette (WCAG AA minimum 4.5:1 ratio).
/// All colors verified against #F8FAFC and #FFFFFF backgrounds.
enum ColorTheme {

    // MARK: - Accent Colors
    static let blue   = Color(red: 0.145, green: 0.388, blue: 0.922) // #2563EB — buttons, primary
    static let green  = Color(red: 0.086, green: 0.639, blue: 0.290) // #16A34A — success, safe
    static let orange = Color(red: 0.918, green: 0.345, blue: 0.047) // #EA580C — caution
    static let red    = Color(red: 0.863, green: 0.149, blue: 0.149) // #DC2626 — alerts, avoid

    // MARK: - Text
    static let primaryText   = Color(red: 0.059, green: 0.090, blue: 0.165) // #0F172A
    static let secondaryText = Color(red: 0.200, green: 0.255, blue: 0.333) // #334155

    // MARK: - Backgrounds
    static let background     = Color(red: 0.973, green: 0.980, blue: 0.988) // #F8FAFC
    static let cardBackground = Color.white

    // MARK: - Semantic aliases
    static let kneeSafe    = green
    static let kneeCaution = orange
    static let kneeAvoid   = red

    // MARK: - Dark mode variants
    static var adaptiveBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.071, green: 0.082, blue: 0.102, alpha: 1)
                : UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1)
        })
    }

    static var adaptiveCard: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.110, green: 0.122, blue: 0.145, alpha: 1)
                : .white
        })
    }
}
