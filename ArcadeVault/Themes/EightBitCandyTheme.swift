import SwiftUI

extension Theme {
    /// Theme C: 8-Bit Candy - chunky pixel vibe, limited bright palette, playful UI
    static let eightBitCandy = Theme(
        id: "eightBitCandy",
        displayName: "8-Bit Candy",
        palette: ThemePalette(
            background: Color(hex: "2B2B5E"),
            backgroundSecondary: Color(hex: "3D3D7A"),
            foreground: Color(hex: "FFFFFF"),
            foregroundSecondary: Color(hex: "DDDDEE"),
            accent: Color(hex: "FF6B9D"),
            accentSecondary: Color(hex: "7FE7DC"),
            danger: Color(hex: "FF4757"),
            success: Color(hex: "2ED573"),
            warning: Color(hex: "FFA502")
        ),
        typography: ThemeTypography(
            titleFont: .system(size: 28, weight: .heavy, design: .rounded),
            headlineFont: .system(size: 18, weight: .bold, design: .rounded),
            bodyFont: .system(size: 15, weight: .medium, design: .rounded),
            captionFont: .system(size: 12, weight: .medium, design: .rounded),
            monoFont: .system(size: 22, weight: .heavy, design: .monospaced)
        ),
        effects: ThemeEffects(
            glowIntensity: 0.0,
            glowRadius: 0,
            scanlineOpacity: 0.0,
            vignetteIntensity: 0.0,
            cornerRadius: 16
        ),
        layout: ThemeLayout(
            gridSpacing: 20,
            tilePadding: 20,
            buttonPadding: EdgeInsets(top: 14, leading: 28, bottom: 14, trailing: 28),
            contentPadding: EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
        )
    )
}
