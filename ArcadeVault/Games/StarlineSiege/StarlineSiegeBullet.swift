import SpriteKit

/// Owner of the bullet (determines direction and collision)
enum BulletOwner {
    case player
    case enemy
}

/// Projectile for Starline Siege
class StarlineSiegeBullet: SKShapeNode {

    // MARK: - Properties

    let owner: BulletOwner
    private let bulletSpeed: CGFloat
    private let angle: CGFloat

    // MARK: - Initialization

    /// Create a bullet
    /// - Parameters:
    ///   - owner: Who fired this bullet
    ///   - color: Bullet color
    ///   - angle: Spread angle in radians (0 = straight, used for multi-shot)
    init(owner: BulletOwner, color: SKColor, angle: CGFloat = 0) {
        self.owner = owner
        self.angle = angle
        self.bulletSpeed = owner == .player ?
            StarlineSiegeConstants.playerBulletSpeed :
            StarlineSiegeConstants.enemyBulletSpeed

        super.init()

        setupShape(color: color)
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape(color: SKColor) {
        let width = StarlineSiegeConstants.bulletWidth
        let height = StarlineSiegeConstants.bulletHeight

        // Create rounded rectangle for bullet
        let path = CGMutablePath()
        path.addRoundedRect(
            in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height),
            cornerWidth: width / 2,
            cornerHeight: width / 2
        )

        self.path = path
        self.fillColor = color
        self.strokeColor = color.withAlphaComponent(0.8)
        self.lineWidth = 1
        self.glowWidth = StarlineSiegeConstants.bulletGlowWidth
        self.name = owner == .player ? "playerBullet" : "enemyBullet"

        // Rotate based on direction and angle spread
        if owner == .player {
            // Player bullets go up, rotate based on spread angle
            self.zRotation = angle
        } else {
            // Enemy bullets go down (180 degrees)
            self.zRotation = .pi
        }
    }

    private func setupPhysics() {
        let width = StarlineSiegeConstants.bulletWidth
        let height = StarlineSiegeConstants.bulletHeight

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.usesPreciseCollisionDetection = true // Prevents tunneling

        if owner == .player {
            physicsBody?.categoryBitMask = StarlineSiegeConstants.playerBulletCategory
            physicsBody?.contactTestBitMask = StarlineSiegeConstants.enemyCategory
        } else {
            physicsBody?.categoryBitMask = StarlineSiegeConstants.enemyBulletCategory
            physicsBody?.contactTestBitMask = StarlineSiegeConstants.playerCategory
        }

        // No physical collisions - only contact detection
        physicsBody?.collisionBitMask = 0
    }

    // MARK: - Movement

    /// Fire the bullet (sets velocity based on owner and angle)
    func fire() {
        let vx: CGFloat
        let vy: CGFloat

        if owner == .player {
            // Player bullets go up with optional spread
            vx = sin(angle) * bulletSpeed
            vy = cos(angle) * bulletSpeed
        } else {
            // Enemy bullets go straight down
            vx = 0
            vy = -bulletSpeed
        }

        physicsBody?.velocity = CGVector(dx: vx, dy: vy)
    }

    // MARK: - Bounds Check

    /// Check if bullet has left the screen
    func isOffScreen(screenHeight: CGFloat) -> Bool {
        position.y < -20 || position.y > screenHeight + 20
    }
}
