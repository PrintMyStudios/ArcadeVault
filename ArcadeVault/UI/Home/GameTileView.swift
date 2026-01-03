import SwiftUI

/// Individual game tile for the home grid
struct GameTileView: View {
    let game: any ArcadeGame
    let action: () -> Void

    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects
        let isAvailable = game.availability == .available

        Button(action: {
            HapticsManager.shared.trigger(.light)
            AudioManager.shared.play(.menuSelect)
            action()
        }) {
            VStack(spacing: 12) {
                // Icon
                ProceduralIconView(
                    style: game.iconStyle,
                    size: Constants.Layout.iconSize,
                    accentColor: isAvailable ? palette.accent : palette.foregroundSecondary,
                    secondaryColor: isAvailable ? palette.accentSecondary : palette.foregroundSecondary.opacity(0.5)
                )
                .opacity(isAvailable ? 1.0 : 0.6)

                VStack(spacing: 4) {
                    // Title
                    Text(game.displayName)
                        .font(theme.typography.headlineFont)
                        .foregroundColor(isAvailable ? palette.foreground : palette.foregroundSecondary)

                    // Description
                    Text(game.description)
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    // Status badge
                    if !isAvailable {
                        Text("COMING SOON")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(palette.warning)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(palette.warning.opacity(0.2))
                            .cornerRadius(4)
                            .padding(.top, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(theme.layout.tilePadding)
            .background(palette.backgroundSecondary)
            .cornerRadius(effects.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: effects.cornerRadius)
                    .stroke(
                        isAvailable ? palette.accent.opacity(0.3) : palette.foregroundSecondary.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .glow(
                color: isAvailable ? palette.accent : .clear,
                radius: effects.glowRadius,
                intensity: isAvailable ? effects.glowIntensity * 0.3 : 0
            )
        }
        .buttonStyle(.plain)
    }
}
