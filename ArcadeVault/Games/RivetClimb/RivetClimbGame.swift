import SpriteKit

/// Rivet Climb - Platform climber style game (COMING SOON)
struct RivetClimbGame: ArcadeGame {
    let id = "rivetClimb"
    let displayName = "Rivet Climb"
    let description = "Ascend the construction site"
    let availability: GameAvailability = .comingSoon
    let iconStyle: GameIconStyle = .platformer

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = RivetClimbScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}
