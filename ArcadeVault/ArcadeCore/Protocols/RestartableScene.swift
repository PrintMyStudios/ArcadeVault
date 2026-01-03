import SpriteKit

/// Protocol for scenes that support game restart
/// Protocols can't inherit from concrete classes, so we use AnyObject
protocol RestartableScene: AnyObject {
    /// Restart the game to its initial state
    func restartGame()
}
