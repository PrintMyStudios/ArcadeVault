import SwiftUI

/// Settings screen
struct SettingsView: View {
    @Environment(\.themeManager) private var themeManager
    @State private var soundEnabled: Bool = PersistenceStore.shared.soundEnabled
    @State private var hapticsEnabled: Bool = PersistenceStore.shared.hapticsEnabled

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette
        let effects = theme.effects

        ScrollView {
            VStack(spacing: 20) {
                // Theme picker
                ThemePickerView()

                // Effects section
                VStack(alignment: .leading, spacing: 12) {
                    Text("EFFECTS")
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary)

                    Toggle(isOn: $themeManager.crtOverlayEnabled) {
                        HStack {
                            Image(systemName: "tv")
                                .foregroundColor(palette.accent)
                            Text("CRT Overlay")
                                .font(theme.typography.bodyFont)
                                .foregroundColor(palette.foreground)
                        }
                    }
                    .tint(palette.accent)
                    .onChange(of: themeManager.crtOverlayEnabled) { _, _ in
                        HapticsManager.shared.trigger(.light)
                    }
                }
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                // Audio & Haptics section
                VStack(alignment: .leading, spacing: 12) {
                    Text("AUDIO & HAPTICS")
                        .font(theme.typography.captionFont)
                        .foregroundColor(palette.foregroundSecondary)

                    Toggle(isOn: $soundEnabled) {
                        HStack {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundColor(palette.accent)
                            Text("Sound Effects")
                                .font(theme.typography.bodyFont)
                                .foregroundColor(palette.foreground)
                        }
                    }
                    .tint(palette.accent)
                    .onChange(of: soundEnabled) { _, newValue in
                        AudioManager.shared.isEnabled = newValue
                        if newValue {
                            AudioManager.shared.play(.menuSelect)
                        }
                    }

                    Toggle(isOn: $hapticsEnabled) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(palette.accent)
                            Text("Haptic Feedback")
                                .font(theme.typography.bodyFont)
                                .foregroundColor(palette.foreground)
                        }
                    }
                    .tint(palette.accent)
                    .onChange(of: hapticsEnabled) { _, newValue in
                        HapticsManager.shared.isEnabled = newValue
                        if newValue {
                            HapticsManager.shared.trigger(.light)
                        }
                    }
                }
                .padding()
                .background(palette.backgroundSecondary)
                .cornerRadius(effects.cornerRadius)

                Spacer(minLength: 40)
            }
            .padding(theme.layout.contentPadding)
        }
        .background(palette.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
