import Foundation

/// Single source of truth for all registered games
final class GameRegistry {
    static let shared = GameRegistry()

    /// All registered games (playable and stubs)
    private(set) var games: [any ArcadeGame] = []

    /// Games available to play
    var availableGames: [any ArcadeGame] {
        games.filter { $0.availability == .available }
    }

    /// Games coming soon
    var comingSoonGames: [any ArcadeGame] {
        games.filter {
            if case .comingSoon = $0.availability { return true }
            return false
        }
    }

    private init() {
        registerGames()
    }

    private func registerGames() {
        games = [
            TestRangeGame(),
            GlyphRunnerGame(),
            StarlineSiegeGame(),
            RivetClimbGame()
        ]
    }

    func game(byId id: String) -> (any ArcadeGame)? {
        games.first { $0.id == id }
    }
}
