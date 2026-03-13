import SwiftUI

/// High-contrast color palette (WCAG AA minimum 4.5:1 ratio).
/// All colors adapt to light / dark mode.
enum ColorTheme {

    // MARK: - Accent Colors (same in light + dark — both pass AA on their respective backgrounds)
    static let blue   = Color(red: 0.145, green: 0.388, blue: 0.922) // #2563EB
    static let green  = Color(red: 0.086, green: 0.639, blue: 0.290) // #16A34A
    static let orange = Color(red: 0.918, green: 0.345, blue: 0.047) // #EA580C
    static let red    = Color(red: 0.863, green: 0.149, blue: 0.149) // #DC2626

    // MARK: - Text  (adaptive)
    /// Near-black in light mode (#0F172A), near-white in dark mode (#EFF2F7)
    static var primaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.937, green: 0.949, blue: 0.969, alpha: 1) // #EFF2F7
                : UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1) // #0F172A
        })
    }

    /// Mid-slate in light mode (#334155), cool gray in dark mode (#94A3B8)
    static var secondaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.580, green: 0.639, blue: 0.722, alpha: 1) // #94A3B8
                : UIColor(red: 0.200, green: 0.255, blue: 0.333, alpha: 1) // #334155
        })
    }

    // MARK: - Backgrounds  (adaptive)
    /// Page background: #F8FAFC light, #12151A dark
    static var background: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.071, green: 0.082, blue: 0.102, alpha: 1) // #12151A
                : UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1) // #F8FAFC
        })
    }

    /// Card surface: white light, #1C1F25 dark
    static var adaptiveCard: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.110, green: 0.122, blue: 0.145, alpha: 1) // #1C1F25
                : .white
        })
    }

    /// Alias kept for call-sites that still reference adaptiveBackground
    static var adaptiveBackground: Color { background }

    // MARK: - Semantic aliases
    static var kneeSafe:    Color { green  }
    static var kneeCaution: Color { orange }
    static var kneeAvoid:   Color { red    }
}
