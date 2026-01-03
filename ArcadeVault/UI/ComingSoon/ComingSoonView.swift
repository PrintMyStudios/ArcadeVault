import SwiftUI

/// Teaser screen for coming soon games
struct ComingSoonView: View {
    let game: any ArcadeGame

    @Environment(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        ZStack {
            palette.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ProceduralIconView(
                    style: game.iconStyle,
                    size: 120,
                    accentColor: palette.accent.opacity(0.6),
                    secondaryColor: palette.accentSecondary.opacity(0.4)
                )
                .glow(color: palette.accent, radius: effects.glowRadius * 2, intensity: effects.glowIntensity * 0.5)

                VStack(spacing: 12) {
                    Text(game.displayName.uppercased())
                        .font(theme.typography.titleFont)
                        .foregroundColor(palette.foreground)

                    Text(game.description)
                        .font(theme.typography.bodyFont)
                        .foregroundColor(palette.foregroundSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                VStack(spacing: 8) {
                    Text("COMING SOON")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(palette.warning)

                    Text("This game is currently in development")
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary)
                }
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                Spacer()

                Button("Back to Vault") {
                    dismiss()
                }
                .buttonStyle(.retro)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
