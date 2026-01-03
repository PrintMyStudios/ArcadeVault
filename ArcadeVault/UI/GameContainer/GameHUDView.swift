import SwiftUI

/// HUD overlay showing score and pause button
struct GameHUDView: View {
    let coordinator: OverlayCoordinator
    let onPause: () -> Void

    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        HStack {
            // Score
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(theme.typography.captionFont)
                    .foregroundColor(palette.foregroundSecondary)

                Text("\(coordinator.score)")
                    .font(theme.typography.monoFont)
                    .foregroundColor(palette.accent)
                    .glow(color: palette.accent, radius: effects.glowRadius / 2, intensity: effects.glowIntensity)
            }

            Spacer()

            // Pause button
            Button(action: {
                HapticsManager.shared.trigger(.light)
                onPause()
            }) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(palette.foreground)
                    .frame(width: 44, height: 44)
                    .background(palette.backgroundSecondary.opacity(0.8))
                    .cornerRadius(effects.cornerRadius / 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .frame(height: Constants.Layout.hudHeight)
    }
}
