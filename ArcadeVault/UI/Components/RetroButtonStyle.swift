import SwiftUI

/// Theme-aware button style with retro feel
struct RetroButtonStyle: ButtonStyle {
    @Environment(\.themeManager) private var themeManager

    var isPrimary: Bool = true
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        let backgroundColor = isDestructive
            ? palette.danger
            : (isPrimary ? palette.accent : palette.backgroundSecondary)
        let foregroundColor = isDestructive || isPrimary
            ? Color.white
            : palette.foreground

        configuration.label
            .font(theme.typography.headlineFont)
            .foregroundColor(foregroundColor)
            .padding(theme.layout.buttonPadding)
            .background(backgroundColor)
            .cornerRadius(effects.cornerRadius)
            .glow(
                color: backgroundColor,
                radius: effects.glowRadius,
                intensity: configuration.isPressed ? 0 : effects.glowIntensity * 0.5
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.themeManager) private var themeManager

    func makeBody(configuration: Configuration) -> some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        configuration.label
            .font(theme.typography.bodyFont)
            .foregroundColor(palette.foreground)
            .padding(theme.layout.buttonPadding)
            .background(palette.backgroundSecondary)
            .cornerRadius(effects.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: effects.cornerRadius)
                    .stroke(palette.accent.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == RetroButtonStyle {
    static var retro: RetroButtonStyle { RetroButtonStyle() }
    static var retroSecondary: RetroButtonStyle { RetroButtonStyle(isPrimary: false) }
    static var retroDestructive: RetroButtonStyle { RetroButtonStyle(isDestructive: true) }
}
