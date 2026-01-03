import SwiftUI

extension Theme {
    /// Theme B: Vector Arcade - phosphor green/amber, crisp vector lines, high contrast
    static let vectorArcade = Theme(
        id: "vectorArcade",
        displayName: "Vector Arcade",
        palette: ThemePalette(
            background: Color(hex: "000000"),
            backgroundSecondary: Color(hex: "0A0A0A"),
            foreground: Color(hex: "33FF33"),
            foregroundSecondary: Color(hex: "228822"),
            accent: Color(hex: "FFAA00"),
            accentSecondary: Color(hex: "33FF33"),
            danger: Color(hex: "FF3333"),
            success: Color(hex: "33FF33"),
            warning: Color(hex: "FFAA00")
        ),
        typography: ThemeTypography(
            titleFont: .system(size: 28, weight: .regular, design: .monospaced),
            headlineFont: .system(size: 18, weight: .regular, design: .monospaced),
            bodyFont: .system(size: 14, weight: .regular, design: .monospaced),
            captionFont: .system(size: 11, weight: .regular, design: .monospaced),
            monoFont: .system(size: 24, weight: .regular, design: .monospaced)
        ),
        effects: ThemeEffects(
            glowIntensity: 0.3,
            glowRadius: 2,
            scanlineOpacity: 0.0,
            vignetteIntensity: 0.2,
            cornerRadius: 0
        ),
        layout: ThemeLayout(
            gridSpacing: 12,
            tilePadding: 12,
            buttonPadding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
            contentPadding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        )
    )
}
