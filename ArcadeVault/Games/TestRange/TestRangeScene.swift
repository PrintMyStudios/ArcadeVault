import SpriteKit

/// Main gameplay scene for Test Range
class TestRangeScene: SKScene, SKPhysicsContactDelegate {

    weak var gameDelegate: GameSceneDelegate?

    private var player: TestRangePlayer!
    private var score: Int = 0
    private var hazardInterval: TimeInterval = TestRangeConstants.initialHazardInterval
    private var isGameActive: Bool = true

    private let playerColor = SKColor(red: 0, green: 1, blue: 1, alpha: 1)
    private let tokenColor = SKColor(red: 1, green: 0, blue: 1, alpha: 1)
    private let hazardColor = SKColor(red: 1, green: 0.2, blue: 0.4, alpha: 1)

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1)

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        setupBoundary()
        setupPlayer()
        startSpawning()

        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }

    private func setupBoundary() {
        let boundary = SKPhysicsBody(edgeLoopFrom: frame)
        boundary.categoryBitMask = TestRangeConstants.boundaryCategory
        boundary.friction = 0
        physicsBody = boundary
    }

    private func setupPlayer() {
        player = TestRangePlayer(color: playerColor)
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(player)
    }

    private func startSpawning() {
        // Token spawning
        let spawnToken = SKAction.sequence([
            SKAction.run { [weak self] in self?.spawnToken() },
            SKAction.wait(forDuration: TestRangeConstants.tokenSpawnInterval)
        ])
        run(SKAction.repeatForever(spawnToken), withKey: "tokenSpawner")

        // Hazard spawning with dynamic interval
        spawnHazardLoop()
    }

    private func spawnHazardLoop() {
        guard isGameActive else { return }

        spawnHazard()

        hazardInterval = max(
            TestRangeConstants.minHazardInterval,
            hazardInterval - TestRangeConstants.hazardIntervalDecrement
        )

        let wait = SKAction.wait(forDuration: hazardInterval)
        let next = SKAction.run { [weak self] in self?.spawnHazardLoop() }
        run(SKAction.sequence([wait, next]), withKey: "hazardSpawner")
    }

    private func spawnToken() {
        guard isGameActive else { return }

        let size = TestRangeConstants.tokenSize
        let token = SKShapeNode(rectOf: CGSize(width: size, height: size))
        token.fillColor = tokenColor
        token.strokeColor = tokenColor.withAlphaComponent(0.8)
        token.lineWidth = 1
        token.glowWidth = 3
        token.name = "token"
        token.zRotation = .pi / 4

        let margin: CGFloat = 40
        let x = CGFloat.random(in: margin...(self.size.width - margin))
        token.position = CGPoint(x: x, y: self.size.height + size)

        token.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
        token.physicsBody?.isDynamic = false
        token.physicsBody?.categoryBitMask = TestRangeConstants.tokenCategory
        token.physicsBody?.contactTestBitMask = TestRangeConstants.playerCategory
        token.physicsBody?.collisionBitMask = 0

        addChild(token)

        let fallDuration = TestRangeConstants.tokenFallSpeed
        let fall = SKAction.moveTo(y: -size, duration: fallDuration)
        let remove = SKAction.removeFromParent()
        token.run(SKAction.sequence([fall, remove]))

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        token.run(SKAction.repeatForever(pulse))
    }

    private func spawnHazard() {
        guard isGameActive else { return }

        let size = TestRangeConstants.hazardSize
        let hazard = SKShapeNode(rectOf: CGSize(width: size, height: size))
        hazard.fillColor = hazardColor
        hazard.strokeColor = hazardColor.withAlphaComponent(0.8)
        hazard.lineWidth = 2
        hazard.glowWidth = 2
        hazard.name = "hazard"

        let margin: CGFloat = 40
        let x = CGFloat.random(in: margin...(self.size.width - margin))
        hazard.position = CGPoint(x: x, y: self.size.height + size)

        hazard.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
        hazard.physicsBody?.isDynamic = false
        hazard.physicsBody?.categoryBitMask = TestRangeConstants.hazardCategory
        hazard.physicsBody?.contactTestBitMask = TestRangeConstants.playerCategory
        hazard.physicsBody?.collisionBitMask = 0

        addChild(hazard)

        let fallDuration = TestRangeConstants.hazardFallSpeed
        let fall = SKAction.moveTo(y: -size, duration: fallDuration)
        let remove = SKAction.removeFromParent()
        hazard.run(SKAction.sequence([fall, remove]))

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 1.5)
        hazard.run(SKAction.repeatForever(rotate))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.setTargetPosition(clampToPlayArea(location))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.setTargetPosition(clampToPlayArea(location))
    }

    private func clampToPlayArea(_ point: CGPoint) -> CGPoint {
        let margin: CGFloat = TestRangeConstants.playerSize / 2
        return CGPoint(
            x: point.x.clamped(to: margin...(size.width - margin)),
            y: point.y.clamped(to: margin...(size.height - margin))
        )
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }
        player.updatePosition()
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == TestRangeConstants.playerCategory | TestRangeConstants.tokenCategory {
            handleTokenCollect(contact)
        } else if collision == TestRangeConstants.playerCategory | TestRangeConstants.hazardCategory {
            handleHazardHit()
        }
    }

    private func handleTokenCollect(_ contact: SKPhysicsContact) {
        let tokenBody = contact.bodyA.categoryBitMask == TestRangeConstants.tokenCategory
            ? contact.bodyA : contact.bodyB
        tokenBody.node?.removeFromParent()

        score += TestRangeConstants.tokenPoints
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .collect)
        gameDelegate?.gameScene(self, requestHaptic: .medium)

        showCollectEffect(at: contact.contactPoint)
    }

    private func showCollectEffect(at point: CGPoint) {
        let effect = SKShapeNode(circleOfRadius: 15)
        effect.fillColor = .clear
        effect.strokeColor = tokenColor
        effect.lineWidth = 2
        effect.position = point
        addChild(effect)

        let expand = SKAction.scale(to: 2.5, duration: 0.25)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        effect.run(SKAction.sequence([SKAction.group([expand, fade]), remove]))
    }

    private func handleHazardHit() {
        guard isGameActive else { return }
        isGameActive = false

        gameDelegate?.gameScene(self, requestSound: .hit)
        gameDelegate?.gameScene(self, requestHaptic: .heavy)

        removeAction(forKey: "tokenSpawner")
        removeAction(forKey: "hazardSpawner")

        let flash = SKAction.sequence([
            SKAction.colorize(with: hazardColor, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(with: backgroundColor, colorBlendFactor: 0.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 3)) { [weak self] in
            guard let self = self else { return }
            self.gameDelegate?.gameScene(self, requestSound: .gameOver)
            self.gameDelegate?.gameSceneDidEnd(self, finalScore: self.score)
        }
    }

    func restartGame() {
        removeAllChildren()
        score = 0
        hazardInterval = TestRangeConstants.initialHazardInterval
        isGameActive = true

        setupBoundary()
        setupPlayer()
        startSpawning()

        gameDelegate?.gameScene(self, didUpdateScore: 0)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }
}
