import SwiftUI
import SpriteKit

/// Container view that hosts SpriteKit game and overlays
struct GameContainerView: View {
    let game: any ArcadeGame

    @Environment(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = OverlayCoordinator()
    @State private var scene: SKScene?

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette

        GeometryReader { geometry in
            ZStack {
                // Game scene
                if let scene = scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                }

                // HUD
                if coordinator.showHUD {
                    VStack {
                        GameHUDView(coordinator: coordinator) {
                            coordinator.pause()
                        }
                        Spacer()
                    }
                }

                // Pause overlay
                if coordinator.showPauseOverlay {
                    PauseOverlayView(
                        onResume: {
                            coordinator.resume()
                        },
                        onRestart: {
                            restartGame()
                        },
                        onExit: {
                            dismiss()
                        }
                    )
                    .transition(.opacity)
                }

                // Game over overlay
                if coordinator.showGameOverOverlay {
                    GameOverOverlayView(
                        coordinator: coordinator,
                        onPlayAgain: {
                            restartGame()
                        },
                        onExit: {
                            dismiss()
                        }
                    )
                    .transition(.opacity)
                }

                // CRT overlay
                if themeManager.crtOverlayEnabled {
                    CRTOverlayView()
                }
            }
            .background(palette.background)
            .onAppear {
                setupScene(size: geometry.size)
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden(true)
    }

    private func setupScene(size: CGSize) {
        let newScene = game.createScene(size: size, delegate: self)
        self.scene = newScene
        coordinator.startGame(gameId: game.id, scene: newScene)
    }

    private func restartGame() {
        if let testRangeScene = scene as? TestRangeScene {
            testRangeScene.restartGame()
            coordinator.restart()
        }
    }
}

// MARK: - GameSceneDelegate

extension GameContainerView: GameSceneDelegate {
    func gameScene(_ scene: SKScene, didUpdateScore score: Int) {
        coordinator.updateScore(score)
    }

    func gameSceneDidEnd(_ scene: SKScene, finalScore: Int) {
        coordinator.endGame(finalScore: finalScore)
    }

    func gameSceneDidRequestPause(_ scene: SKScene) {
        coordinator.pause()
    }

    func gameScene(_ scene: SKScene, requestHaptic type: HapticType) {
        HapticsManager.shared.trigger(type)
    }

    func gameScene(_ scene: SKScene, requestSound type: SoundType) {
        AudioManager.shared.play(type)
    }
}
