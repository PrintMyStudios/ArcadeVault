import SpriteKit

/// Enemy types with different properties
enum EnemyType: CaseIterable {
    case basic    // Square, 1 HP, 10 pts
    case fast     // Diamond, 1 HP, 15 pts
    case heavy    // Hexagon, 2 HP, 25 pts

    var health: Int {
        switch self {
        case .basic: return 1
        case .fast: return 1
        case .heavy: return 2
        }
    }

    var points: Int {
        switch self {
        case .basic: return StarlineSiegeConstants.basicEnemyPoints
        case .fast: return StarlineSiegeConstants.fastEnemyPoints
        case .heavy: return StarlineSiegeConstants.heavyEnemyPoints
        }
    }
}

/// Enemy ship for Starline Siege
class StarlineSiegeEnemy: SKShapeNode {

    // MARK: - Properties

    let enemyType: EnemyType
    private(set) var health: Int
    let row: Int
    let column: Int

    // MARK: - Visual

    private let baseColor: SKColor
    private let damageColor: SKColor
    private let enemyWidth: CGFloat
    private let enemyHeight: CGFloat

    // MARK: - Initialization

    init(type: EnemyType, row: Int, column: Int, color: SKColor, damageColor: SKColor, screenSize: CGSize) {
        self.enemyType = type
        self.health = type.health
        self.row = row
        self.column = column
        self.baseColor = color
        self.damageColor = damageColor
        self.enemyWidth = screenSize.width * StarlineSiegeConstants.enemyWidthRatio
        self.enemyHeight = screenSize.height * StarlineSiegeConstants.enemyHeightRatio

        super.init()

        setupShape()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape() {
        let path: CGPath
        switch enemyType {
        case .basic:
            path = createSquarePath()
        case .fast:
            path = createDiamondPath()
        case .heavy:
            path = createHexagonPath()
        }

        self.path = path
        self.fillColor = baseColor
        self.strokeColor = baseColor.withAlphaComponent(0.8)
        self.lineWidth = 2
        self.glowWidth = StarlineSiegeConstants.enemyGlowWidth
        self.name = "enemy"

        // Add inner detail for visual interest
        addInnerDetail()
    }

    private func createSquarePath() -> CGPath {
        let path = CGMutablePath()
        let w = enemyWidth / 2
        let h = enemyHeight / 2
        path.addRect(CGRect(x: -w, y: -h, width: enemyWidth, height: enemyHeight))
        return path
    }

    private func createDiamondPath() -> CGPath {
        let path = CGMutablePath()
        let w = enemyWidth / 2
        let h = enemyHeight / 2

        path.move(to: CGPoint(x: 0, y: h))      // Top
        path.addLine(to: CGPoint(x: w, y: 0))   // Right
        path.addLine(to: CGPoint(x: 0, y: -h))  // Bottom
        path.addLine(to: CGPoint(x: -w, y: 0))  // Left
        path.closeSubpath()

        return path
    }

    private func createHexagonPath() -> CGPath {
        let path = CGMutablePath()
        let radius = min(enemyWidth, enemyHeight) / 2

        for i in 0..<6 {
            let angle = CGFloat(i) * (.pi / 3) - .pi / 6 // Start at -30 degrees
            let x = cos(angle) * radius
            let y = sin(angle) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        return path
    }

    private func addInnerDetail() {
        // Add a small inner shape for visual interest
        let innerSize = min(enemyWidth, enemyHeight) * 0.25
        let inner = SKShapeNode(circleOfRadius: innerSize)
        inner.fillColor = baseColor.withAlphaComponent(0.5)
        inner.strokeColor = .clear
        inner.name = "innerDetail"
        addChild(inner)
    }

    private func setupPhysics() {
        let physicsSize = CGSize(width: enemyWidth * 0.8, height: enemyHeight * 0.8)
        physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = StarlineSiegeConstants.enemyCategory
        physicsBody?.contactTestBitMask = StarlineSiegeConstants.playerBulletCategory |
                                          StarlineSiegeConstants.playerCategory
        physicsBody?.collisionBitMask = 0
    }

    // MARK: - Damage

    /// Apply damage to enemy. Returns true if destroyed.
    func takeDamage() -> Bool {
        health -= 1

        if health > 0 {
            // Still alive - show damage flash
            let flash = SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.fillColor = self?.damageColor ?? .white
                },
                SKAction.wait(forDuration: 0.1),
                SKAction.run { [weak self] in
                    self?.fillColor = self?.baseColor ?? .red
                }
            ])
            run(flash, withKey: "damageFlash")
            return false
        }

        return true // Destroyed
    }

    // MARK: - Animation

    func startIdleAnimation() {
        // Subtle bobbing animation
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.4),
            SKAction.moveBy(x: 0, y: -3, duration: 0.4)
        ])
        run(SKAction.repeatForever(bob), withKey: "idleBob")
    }

    func stopIdleAnimation() {
        removeAction(forKey: "idleBob")
    }
}
