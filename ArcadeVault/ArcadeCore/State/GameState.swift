import Foundation

/// Represents the current state of gameplay
enum GameState: Equatable {
    case idle
    case playing
    case paused
    case gameOver
}
