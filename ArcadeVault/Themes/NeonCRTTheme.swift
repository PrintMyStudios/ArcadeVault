import SwiftUI

extension Theme {
    /// Theme A: Neon CRT - dark background, neon accents, soft glow, scanlines
    static let neonCRT = Theme(
        id: "neonCRT",
        displayName: "Neon CRT",
        palette: ThemePalette(
            background: Color(hex: "0D0D1A"),
            backgroundSecondary: Color(hex: "1A1A2E"),
            foreground: Color(hex: "FFFFFF"),
            foregroundSecondary: Color(hex: "B0B0C0"),
            accent: Color(hex: "FF00FF"),
            accentSecondary: Color(hex: "00FFFF"),
            danger: Color(hex: "FF3366"),
            success: Color(hex: "00FF88"),
            warning: Color(hex: "FFAA00")
        ),
        typography: ThemeTypography(
            titleFont: .system(size: 32, weight: .bold, design: .rounded),
            headlineFont: .system(size: 20, weight: .semibold, design: .rounded),
            bodyFont: .system(size: 16, weight: .regular, design: .rounded),
            captionFont: .system(size: 12, weight: .regular, design: .rounded),
            monoFont: .system(size: 24, weight: .bold, design: .monospaced)
        ),
        effects: ThemeEffects(
            glowIntensity: 0.8,
            glowRadius: 8,
            scanlineOpacity: 0.15,
            vignetteIntensity: 0.4,
            cornerRadius: 12
        ),
        layout: ThemeLayout(
            gridSpacing: 16,
            tilePadding: 16,
            buttonPadding: EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24),
            contentPadding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        )
    )
}
