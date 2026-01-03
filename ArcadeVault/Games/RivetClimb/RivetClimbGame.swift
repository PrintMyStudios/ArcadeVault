import SpriteKit

/// Rivet Climb - Platform climber style game
/// Climb platforms via ladders, avoid rolling bolts and falling crates, collect rivets, seal the hatch!
struct RivetClimbGame: ArcadeGame {
    let id = "rivetClimb"
    let displayName = "Rivet Climb"
    let description = "Ascend the construction site"
    let availability: GameAvailability = .available
    let iconStyle: GameIconStyle = .platformer

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = RivetClimbScene(size: size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = delegate
        return scene
    }
}
