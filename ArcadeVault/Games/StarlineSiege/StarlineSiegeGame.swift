import SpriteKit

/// Starline Siege - Fixed shooter style game (COMING SOON)
struct StarlineSiegeGame: ArcadeGame {
    let id = "starlineSiege"
    let displayName = "Starline Siege"
    let description = "Defend the frontier from waves of invaders"
    let availability: GameAvailability = .comingSoon
    let iconStyle: GameIconStyle = .fixedShooter

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = StarlineSiegeScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}
