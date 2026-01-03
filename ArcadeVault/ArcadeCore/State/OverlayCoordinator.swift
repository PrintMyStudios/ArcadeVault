import SwiftUI
import SpriteKit

/// Manages game state transitions and overlay visibility
@Observable
final class OverlayCoordinator {
    /// Current game state
    var gameState: GameState = .playing

    /// Current score
    var score: Int = 0

    /// Best score for current game
    var bestScore: Int = 0

    /// Whether this is a new high score
    var isNewHighScore: Bool = false

    /// The game being played
    private(set) var currentGameId: String = ""

    /// Reference to the scene for pause/resume
    weak var scene: SKScene?

    /// Whether HUD should be visible
    var showHUD: Bool {
        gameState == .playing || gameState == .paused
    }

    /// Whether pause overlay should be visible
    var showPauseOverlay: Bool {
        gameState == .paused
    }

    /// Whether game over overlay should be visible
    var showGameOverOverlay: Bool {
        gameState == .gameOver
    }

    func startGame(gameId: String, scene: SKScene) {
        self.currentGameId = gameId
        self.scene = scene
        self.score = 0
        self.bestScore = PersistenceStore.shared.bestScore(for: gameId)
        self.isNewHighScore = false
        self.gameState = .playing
        scene.isPaused = false
    }

    func pause() {
        guard gameState == .playing else { return }
        gameState = .paused
        scene?.isPaused = true
    }

    func resume() {
        guard gameState == .paused else { return }
        gameState = .playing
        scene?.isPaused = false
    }

    func endGame(finalScore: Int) {
        score = finalScore
        if finalScore > bestScore {
            bestScore = finalScore
            isNewHighScore = true
            PersistenceStore.shared.setBestScore(finalScore, for: currentGameId)
        }
        gameState = .gameOver
        scene?.isPaused = true
    }

    func updateScore(_ newScore: Int) {
        score = newScore
    }

    func restart() {
        score = 0
        isNewHighScore = false
        gameState = .playing
        scene?.isPaused = false
    }

    func reset() {
        gameState = .idle
        score = 0
        currentGameId = ""
        scene = nil
    }
}
