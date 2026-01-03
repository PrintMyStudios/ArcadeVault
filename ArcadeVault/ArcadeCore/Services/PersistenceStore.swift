import Foundation

/// UserDefaults wrapper for all app persistence
final class PersistenceStore {
    static let shared = PersistenceStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let selectedThemeId = "arcade.selectedThemeId"
        static let crtOverlayEnabled = "arcade.crtOverlayEnabled"
        static let soundEnabled = "arcade.soundEnabled"
        static let hapticsEnabled = "arcade.hapticsEnabled"

        static func bestScore(for gameId: String) -> String {
            "arcade.bestScore.\(gameId)"
        }
    }

    // MARK: - Theme

    var selectedThemeId: String {
        get { defaults.string(forKey: Keys.selectedThemeId) ?? "neonCRT" }
        set { defaults.set(newValue, forKey: Keys.selectedThemeId) }
    }

    var crtOverlayEnabled: Bool {
        get { defaults.bool(forKey: Keys.crtOverlayEnabled) }
        set { defaults.set(newValue, forKey: Keys.crtOverlayEnabled) }
    }

    // MARK: - Audio & Haptics

    var soundEnabled: Bool {
        get { defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.soundEnabled) }
    }

    var hapticsEnabled: Bool {
        get { defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.hapticsEnabled) }
    }

    // MARK: - Scores

    func bestScore(for gameId: String) -> Int {
        defaults.integer(forKey: Keys.bestScore(for: gameId))
    }

    func setBestScore(_ score: Int, for gameId: String) {
        defaults.set(score, forKey: Keys.bestScore(for: gameId))
    }

    // MARK: - Init

    private init() {}
}
