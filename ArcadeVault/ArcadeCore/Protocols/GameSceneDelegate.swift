import SpriteKit

/// Haptic feedback types
enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
}

/// Sound effect types
enum SoundType {
    case menuSelect
    case gameStart
    case collect
    case hit
    case gameOver
}

/// Communication protocol from SKScene back to SwiftUI container
protocol GameSceneDelegate: AnyObject {
    /// Called when score changes
    func gameScene(_ scene: SKScene, didUpdateScore score: Int)

    /// Called when game ends
    func gameSceneDidEnd(_ scene: SKScene, finalScore: Int)

    /// Request to pause the game
    func gameSceneDidRequestPause(_ scene: SKScene)

    /// Request haptic feedback
    func gameScene(_ scene: SKScene, requestHaptic type: HapticType)

    /// Request sound effect
    func gameScene(_ scene: SKScene, requestSound type: SoundType)
}
