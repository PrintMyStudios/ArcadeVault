import SwiftUI

/// Game over screen overlay
struct GameOverOverlayView: View {
    let coordinator: OverlayCoordinator
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        ZStack {
            // Dimmed background
            palette.background.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("GAME OVER")
                    .font(theme.typography.titleFont)
                    .foregroundColor(palette.danger)
                    .glow(color: palette.danger, radius: effects.glowRadius, intensity: effects.glowIntensity)

                // Scores
                VStack(spacing: 16) {
                    // Final score
                    VStack(spacing: 4) {
                        Text("SCORE")
                            .font(theme.typography.captionFont)
                            .foregroundColor(palette.foregroundSecondary)

                        Text("\(coordinator.score)")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(palette.accent)
                            .glow(color: palette.accent, radius: effects.glowRadius, intensity: effects.glowIntensity)
                    }

                    // High score indicator
                    if coordinator.isNewHighScore {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                            Text("NEW HIGH SCORE!")
                            Image(systemName: "star.fill")
                        }
                        .font(theme.typography.headlineFont)
                        .foregroundColor(palette.warning)
                        .glow(color: palette.warning, radius: effects.glowRadius / 2, intensity: effects.glowIntensity)
                    }

                    // Best score
                    HStack(spacing: 8) {
                        Text("BEST:")
                            .font(theme.typography.captionFont)
                            .foregroundColor(palette.foregroundSecondary)

                        Text("\(coordinator.bestScore)")
                            .font(theme.typography.monoFont)
                            .foregroundColor(palette.foregroundSecondary)
                    }
                }
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                // Actions
                VStack(spacing: 16) {
                    Button("Play Again") {
                        HapticsManager.shared.trigger(.medium)
                        AudioManager.shared.play(.menuSelect)
                        onPlayAgain()
                    }
                    .buttonStyle(.retro)

                    Button("Exit to Vault") {
                        HapticsManager.shared.trigger(.light)
                        AudioManager.shared.play(.menuSelect)
                        onExit()
                    }
                    .buttonStyle(RetroButtonStyle(isPrimary: false))
                }
            }
            .padding(40)
        }
    }
}
