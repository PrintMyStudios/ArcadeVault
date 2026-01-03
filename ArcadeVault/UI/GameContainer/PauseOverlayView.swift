import SwiftUI

/// Pause menu overlay
struct PauseOverlayView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        ZStack {
            // Dimmed background
            palette.background.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("PAUSED")
                    .font(theme.typography.titleFont)
                    .foregroundColor(palette.foreground)
                    .glow(color: palette.accent, radius: effects.glowRadius, intensity: effects.glowIntensity * 0.5)

                VStack(spacing: 16) {
                    Button("Resume") {
                        HapticsManager.shared.trigger(.light)
                        AudioManager.shared.play(.menuSelect)
                        onResume()
                    }
                    .buttonStyle(.retro)

                    Button("Restart") {
                        HapticsManager.shared.trigger(.medium)
                        AudioManager.shared.play(.menuSelect)
                        onRestart()
                    }
                    .buttonStyle(RetroButtonStyle(isPrimary: false))

                    Button("Exit to Vault") {
                        HapticsManager.shared.trigger(.light)
                        AudioManager.shared.play(.menuSelect)
                        onExit()
                    }
                    .buttonStyle(RetroButtonStyle(isPrimary: false))
                }
            }
            .padding(40)
            .background(palette.backgroundSecondary)
            .cornerRadius(effects.cornerRadius)
        }
    }
}
