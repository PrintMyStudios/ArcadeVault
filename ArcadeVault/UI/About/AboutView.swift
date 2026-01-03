import SwiftUI

/// Credits and version info screen
struct AboutView: View {
    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                // App icon / logo area
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: effects.cornerRadius * 2)
                            .fill(palette.backgroundSecondary)
                            .frame(width: 100, height: 100)

                        Text("AV")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(palette.accent)
                            .glow(color: palette.accent, radius: effects.glowRadius, intensity: effects.glowIntensity)
                    }

                    VStack(spacing: 4) {
                        Text(AppBrand.appDisplayName)
                            .font(theme.typography.titleFont)
                            .foregroundColor(palette.foreground)

                        Text(AppBrand.appSubtitle)
                            .font(theme.typography.captionFont)
                            .foregroundColor(palette.foregroundSecondary)
                    }
                }

                // Version info
                VStack(spacing: 8) {
                    Text("Version \(AppBrand.version) (\(AppBrand.build))")
                        .font(theme.typography.bodyFont)
                        .foregroundColor(palette.foregroundSecondary)

                    Text(AppBrand.copyright)
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary.opacity(0.7))
                }
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                // Credits section
                VStack(alignment: .leading, spacing: 12) {
                    Text("CREDITS")
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary)

                    VStack(alignment: .leading, spacing: 8) {
                        CreditRow(role: "Design & Development", name: "Arcade Vault Team")
                        CreditRow(role: "Framework", name: "SwiftUI + SpriteKit")
                        CreditRow(role: "Audio", name: "Procedural Generation")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                // Acknowledgments
                VStack(spacing: 8) {
                    Text("Original Games Only")
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.warning)

                    Text("All games in Arcade Vault are original creations inspired by classic arcade mechanics. No trademarked titles, assets, or designs are used.")
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                Spacer(minLength: 40)
            }
            .padding(theme.layout.contentPadding)
        }
        .background(palette.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreditRow: View {
    let role: String
    let name: String

    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette

        HStack {
            Text(role)
                .font(theme.typography.captionFont)
                .foregroundColor(palette.foregroundSecondary)

            Spacer()

            Text(name)
                .font(theme.typography.bodyFont)
                .foregroundColor(palette.foreground)
        }
    }
}
