import SpriteKit

/// Player node for Test Range
class TestRangePlayer: SKShapeNode {
    private var targetPosition: CGPoint?

    init(color: SKColor) {
        super.init()

        let size = TestRangeConstants.playerSize
        let path = CGPath(ellipseIn: CGRect(x: -size/2, y: -size/2, width: size, height: size), transform: nil)
        self.path = path
        self.fillColor = color
        self.strokeColor = color.withAlphaComponent(0.8)
        self.lineWidth = 2
        self.glowWidth = 4
        self.name = "player"

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        let size = TestRangeConstants.playerSize
        physicsBody = SKPhysicsBody(circleOfRadius: size / 2)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = TestRangeConstants.playerCategory
        physicsBody?.contactTestBitMask = TestRangeConstants.tokenCategory | TestRangeConstants.hazardCategory
        physicsBody?.collisionBitMask = TestRangeConstants.boundaryCategory
    }

    func setTargetPosition(_ point: CGPoint) {
        targetPosition = point
    }

    func updatePosition() {
        guard let target = targetPosition else { return }

        let newPosition = position.lerp(to: target, t: TestRangeConstants.playerSpeed)
        position = newPosition
    }
}
