import SpriteKit

/// Availability status for games in the registry
enum GameAvailability: Equatable {
    case available
    case comingSoon
    case locked(reason: String)
}

/// Icon style for procedural generation
enum GameIconStyle {
    case testRange
    case mazeChase
    case fixedShooter
    case platformer
}

/// Protocol that all games must conform to for registration
protocol ArcadeGame: Identifiable {
    /// Unique identifier (used for persistence keys)
    var id: String { get }

    /// Display name shown on tile
    var displayName: String { get }

    /// Short description for tile subtitle
    var description: String { get }

    /// Whether the game is playable
    var availability: GameAvailability { get }

    /// Icon style for procedural rendering
    var iconStyle: GameIconStyle { get }

    /// Factory method to create the game scene
    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene
}
