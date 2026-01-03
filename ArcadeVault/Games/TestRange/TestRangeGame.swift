import SpriteKit

/// Test Range - Collect tokens, dodge hazards (PLAYABLE)
struct TestRangeGame: ArcadeGame {
    let id = "testRange"
    let displayName = "Test Range"
    let description = "Collect tokens, dodge hazards"
    let availability: GameAvailability = .available
    let iconStyle: GameIconStyle = .testRange

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = TestRangeScene(size: size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = delegate
        return scene
    }
}
