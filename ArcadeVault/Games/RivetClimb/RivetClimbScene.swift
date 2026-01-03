import SpriteKit

/// Placeholder scene for Rivet Climb
class RivetClimbScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let label = SKLabelNode(text: "RIVET CLIMB")
        label.fontName = "Menlo-Bold"
        label.fontSize = 28
        label.fontColor = .orange
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        addChild(label)

        let subtitle = SKLabelNode(text: "Coming Soon")
        subtitle.fontName = "Menlo"
        subtitle.fontSize = 18
        subtitle.fontColor = .gray
        subtitle.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        addChild(subtitle)
    }
}
