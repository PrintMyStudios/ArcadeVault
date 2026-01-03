import SpriteKit

/// Glyph Runner - Maze chase style game (COMING SOON)
struct GlyphRunnerGame: ArcadeGame {
    let id = "glyphRunner"
    let displayName = "Glyph Runner"
    let description = "Navigate the ever-shifting maze"
    let availability: GameAvailability = .comingSoon
    let iconStyle: GameIconStyle = .mazeChase

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = GlyphRunnerScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}
