import SwiftUI

/// Observable theme state manager
@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    /// All available themes
    let availableThemes: [Theme] = Theme.allThemes

    /// Currently selected theme
    var currentTheme: Theme {
        didSet {
            PersistenceStore.shared.selectedThemeId = currentTheme.id
        }
    }

    /// CRT overlay toggle
    var crtOverlayEnabled: Bool {
        didSet {
            PersistenceStore.shared.crtOverlayEnabled = crtOverlayEnabled
        }
    }

    private init() {
        let savedThemeId = PersistenceStore.shared.selectedThemeId
        self.currentTheme = Theme.theme(for: savedThemeId)
        self.crtOverlayEnabled = PersistenceStore.shared.crtOverlayEnabled
    }

    func selectTheme(_ theme: Theme) {
        currentTheme = theme
    }

    func selectTheme(byId id: String) {
        if let theme = availableThemes.first(where: { $0.id == id }) {
            currentTheme = theme
        }
    }
}

// MARK: - Environment Key

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
