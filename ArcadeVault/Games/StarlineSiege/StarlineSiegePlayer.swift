import SpriteKit

/// Power-up types that can be collected
enum PowerUpType: CaseIterable {
    case shield
    case rapidFire
    case multiShot
}

/// Player ship for Starline Siege
class StarlineSiegePlayer: SKShapeNode {

    // MARK: - Movement State

    private var targetX: CGFloat = 0
    private let smoothing: CGFloat
    private let minX: CGFloat
    private let maxX: CGFloat

    // MARK: - Shooting State

    private var lastShotTime: TimeInterval = 0
    private var currentCooldown: TimeInterval
    private let defaultCooldown: TimeInterval

    // MARK: - Power-Up State

    private(set) var hasShield: Bool = false
    private(set) var hasRapidFire: Bool = false
    private(set) var hasMultiShot: Bool = false
    private var shieldNode: SKShapeNode?

    // MARK: - Invincibility

    private(set) var isInvincible: Bool = false

    // MARK: - Visual

    private let playerWidth: CGFloat
    private let playerHeight: CGFloat
    private let baseColor: SKColor
    private let screenSize: CGSize

    // MARK: - Initialization

    init(color: SKColor, screenSize: CGSize) {
        self.baseColor = color
        self.screenSize = screenSize
        self.playerWidth = screenSize.width * StarlineSiegeConstants.playerWidthRatio
        self.playerHeight = screenSize.height * StarlineSiegeConstants.playerHeightRatio
        self.smoothing = StarlineSiegeConstants.playerMoveSmoothing
        self.defaultCooldown = StarlineSiegeConstants.shootCooldown
        self.currentCooldown = defaultCooldown

        // Calculate horizontal bounds
        let margin = playerWidth / 2 + 10
        self.minX = margin
        self.maxX = screenSize.width - margin

        super.init()

        setupShape()
        setupPhysics()

        // Initial position at bottom center
        let startX = screenSize.width / 2
        let startY = StarlineSiegeConstants.playerBottomMargin + playerHeight / 2
        position = CGPoint(x: startX, y: startY)
        targetX = startX
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape() {
        let path = createChevronPath()
        self.path = path
        self.fillColor = baseColor
        self.strokeColor = baseColor.withAlphaComponent(0.8)
        self.lineWidth = 2
        self.glowWidth = StarlineSiegeConstants.playerGlowWidth
        self.name = "player"
    }

    private func createChevronPath() -> CGPath {
        let path = CGMutablePath()
        let w = playerWidth / 2
        let h = playerHeight / 2

        // Chevron/arrow shape pointing up
        path.move(to: CGPoint(x: 0, y: h))              // Top center (nose)
        path.addLine(to: CGPoint(x: w, y: -h))          // Bottom right
        path.addLine(to: CGPoint(x: w * 0.3, y: -h * 0.3)) // Inner notch right
        path.addLine(to: CGPoint(x: 0, y: -h * 0.6))    // Center notch
        path.addLine(to: CGPoint(x: -w * 0.3, y: -h * 0.3)) // Inner notch left
        path.addLine(to: CGPoint(x: -w, y: -h))         // Bottom left
        path.closeSubpath()

        return path
    }

    private func setupPhysics() {
        let physicsSize = CGSize(width: playerWidth * 0.7, height: playerHeight * 0.7)
        physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = StarlineSiegeConstants.playerCategory
        physicsBody?.contactTestBitMask = StarlineSiegeConstants.enemyCategory |
                                          StarlineSiegeConstants.enemyBulletCategory |
                                          StarlineSiegeConstants.powerUpCategory
        physicsBody?.collisionBitMask = 0
    }

    // MARK: - Movement

    /// Set target X position (called from touch handling)
    func setTargetX(_ x: CGFloat) {
        targetX = min(max(x, minX), maxX)
    }

    /// Update position with smooth interpolation (called each frame)
    func updatePosition() {
        let diff = targetX - position.x
        position.x += diff * smoothing
    }

    // MARK: - Shooting

    /// Check if player can shoot based on cooldown
    func canShoot(currentTime: TimeInterval) -> Bool {
        currentTime - lastShotTime >= currentCooldown
    }

    /// Record that a shot was fired
    func recordShot(at time: TimeInterval) {
        lastShotTime = time
    }

    /// Get the position where bullets should spawn
    func getBulletSpawnPosition() -> CGPoint {
        CGPoint(x: position.x, y: position.y + playerHeight / 2 + 5)
    }

    /// Get number of bullets to fire (1 normally, 3 with multi-shot)
    func getShotCount() -> Int {
        hasMultiShot ? 3 : 1
    }

    // MARK: - Power-Ups

    func activateShield(color: SKColor) {
        hasShield = true

        // Create visual shield bubble
        let shieldRadius = max(playerWidth, playerHeight) * 0.8
        let shield = SKShapeNode(circleOfRadius: shieldRadius)
        shield.fillColor = color.withAlphaComponent(0.15)
        shield.strokeColor = color
        shield.lineWidth = 2
        shield.glowWidth = 5
        shield.name = "shieldVisual"
        addChild(shield)
        shieldNode = shield

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.4),
            SKAction.scale(to: 1.0, duration: 0.4)
        ])
        shield.run(SKAction.repeatForever(pulse), withKey: "shieldPulse")
    }

    func deactivateShield() {
        hasShield = false
        shieldNode?.removeFromParent()
        shieldNode = nil
    }

    func activateRapidFire() {
        hasRapidFire = true
        currentCooldown = StarlineSiegeConstants.rapidFireCooldown
    }

    func deactivateRapidFire() {
        hasRapidFire = false
        currentCooldown = defaultCooldown
    }

    func activateMultiShot() {
        hasMultiShot = true
    }

    func deactivateMultiShot() {
        hasMultiShot = false
    }

    // MARK: - Invincibility

    func startInvincibility(duration: TimeInterval) {
        guard !isInvincible else { return }
        isInvincible = true

        // Blinking effect
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let blinkCount = Int(duration / 0.2)
        run(SKAction.repeat(blink, count: blinkCount), withKey: "invincibilityBlink")

        // End invincibility after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                self?.endInvincibility()
            }
        ]), withKey: "invincibilityTimer")
    }

    private func endInvincibility() {
        isInvincible = false
        removeAction(forKey: "invincibilityBlink")
        alpha = 1.0
    }

    // MARK: - Reset

    func reset() {
        // Reset position
        position = CGPoint(
            x: screenSize.width / 2,
            y: StarlineSiegeConstants.playerBottomMargin + playerHeight / 2
        )
        targetX = position.x

        // Reset shooting
        lastShotTime = 0
        currentCooldown = defaultCooldown

        // Clear all power-ups
        deactivateShield()
        deactivateRapidFire()
        deactivateMultiShot()

        // Clear invincibility
        isInvincible = false
        removeAction(forKey: "invincibilityBlink")
        removeAction(forKey: "invincibilityTimer")
        alpha = 1.0
    }
}
