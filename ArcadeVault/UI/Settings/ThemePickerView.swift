import SwiftUI

/// Theme selection UI
struct ThemePickerView: View {
    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        VStack(alignment: .leading, spacing: 12) {
            Text("THEME")
                .font(theme.typography.captionFont)
                .foregroundColor(palette.foregroundSecondary)

            ForEach(themeManager.availableThemes) { availableTheme in
                ThemeOptionRow(
                    theme: availableTheme,
                    isSelected: themeManager.currentTheme.id == availableTheme.id
                ) {
                    HapticsManager.shared.trigger(.light)
                    AudioManager.shared.play(.menuSelect)
                    themeManager.selectTheme(availableTheme)
                }
            }
        }
        .padding()
        .background(palette.backgroundSecondary)
        .cornerRadius(effects.cornerRadius)
    }
}

struct ThemeOptionRow: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let currentTheme = themeManager.currentTheme
        let palette = currentTheme.palette
        let effects = currentTheme.effects

        Button(action: action) {
            HStack(spacing: 12) {
                // Color preview
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.palette.accent)
                        .frame(width: 16, height: 16)
                    Circle()
                        .fill(theme.palette.accentSecondary)
                        .frame(width: 16, height: 16)
                    Circle()
                        .fill(theme.palette.background)
                        .stroke(palette.foregroundSecondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 16, height: 16)
                }

                Text(theme.displayName)
                    .font(currentTheme.typography.bodyFont)
                    .foregroundColor(palette.foreground)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(palette.success)
                }
            }
            .padding(12)
            .background(isSelected ? palette.accent.opacity(0.1) : Color.clear)
            .cornerRadius(effects.cornerRadius / 2)
            .overlay(
                RoundedRectangle(cornerRadius: effects.cornerRadius / 2)
                    .stroke(isSelected ? palette.accent.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
