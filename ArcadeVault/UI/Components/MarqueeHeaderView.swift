import SwiftUI

/// App title marquee header
struct MarqueeHeaderView: View {
    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        VStack(spacing: 4) {
            Text(AppBrand.appDisplayName.uppercased())
                .font(theme.typography.titleFont)
                .foregroundColor(palette.accent)
                .glow(color: palette.accent, radius: effects.glowRadius, intensity: effects.glowIntensity)

            Text(AppBrand.appSubtitle)
                .font(theme.typography.captionFont)
                .foregroundColor(palette.foregroundSecondary)
        }
        .padding(.vertical, 8)
    }
}
