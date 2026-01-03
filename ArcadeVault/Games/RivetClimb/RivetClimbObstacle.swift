import SpriteKit

// MARK: - Obstacle Type

/// Types of obstacles
enum ObstacleType {
    case rolling  // Bolts that roll horizontally
    case falling  // Crates that fall vertically

    /// Random type based on run level difficulty
    static func random(for runLevel: Int) -> ObstacleType {
        let rollerPercent = RivetClimbConstants.rollerPercent(for: runLevel)
        return Int.random(in: 1...100) <= rollerPercent ? .rolling : .falling
    }
}

// MARK: - Obstacle Class

/// A grid-driven obstacle (rolling bolt or falling crate)
class RivetClimbObstacle: SKShapeNode {

    // MARK: - Properties

    /// Type of obstacle
    let obstacleType: ObstacleType

    /// Current grid column
    private(set) var col: Int

    /// Current grid row
    private(set) var row: Int

    /// Direction of movement (1 = right, -1 = left) for rolling
    private(set) var direction: Int

    /// Reference to level for movement checks
    weak var level: RivetClimbLevel?

    /// Current run level (for drop-through chance)
    private let runLevel: Int

    /// Whether obstacle is currently animating between cells
    private(set) var isMoving: Bool = false

    /// Progress through current movement
    private var moveProgress: CGFloat = 0

    /// Starting position for animation
    private var moveStartPosition: CGPoint = .zero

    /// Target position for animation
    private var moveTargetPosition: CGPoint = .zero

    /// Duration of move animation
    private let moveAnimationDuration: TimeInterval = 0.15

    /// Size of obstacle
    private let obstacleSize: CGFloat

    // MARK: - Initialization

    init(type: ObstacleType, color: SKColor, level: RivetClimbLevel, spawnPosition: LevelPosition, runLevel: Int) {
        self.obstacleType = type
        self.col = spawnPosition.col
        self.row = spawnPosition.row
        self.level = level
        self.runLevel = runLevel
        self.obstacleSize = level.tileSize.width * RivetClimbConstants.obstacleSizeRatio

        // Random initial direction for rolling
        self.direction = Bool.random() ? 1 : -1

        super.init()

        setupShape(color: color)

        // Set initial position
        self.position = level.worldPosition(col: col, row: row)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape(color: SKColor) {
        let path: CGPath

        switch obstacleType {
        case .rolling:
            // Bolt: hexagon shape
            path = createBoltPath()
        case .falling:
            // Crate: square shape
            path = createCratePath()
        }

        self.path = path
        self.fillColor = color
        self.strokeColor = color.withAlphaComponent(0.8)
        self.lineWidth = 1.5
        self.glowWidth = RivetClimbConstants.obstacleGlowWidth
    }

    private func createBoltPath() -> CGPath {
        let path = CGMutablePath()
        let radius = obstacleSize / 2

        // Hexagon
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        // Inner detail (small circle)
        let innerRadius = radius * 0.3
        path.addEllipse(in: CGRect(x: -innerRadius, y: -innerRadius, width: innerRadius * 2, height: innerRadius * 2))

        return path
    }

    private func createCratePath() -> CGPath {
        let path = CGMutablePath()
        let size = obstacleSize * 0.9

        // Square
        path.addRect(CGRect(x: -size / 2, y: -size / 2, width: size, height: size))

        // X pattern inside
        let inset = size * 0.2
        path.move(to: CGPoint(x: -size / 2 + inset, y: -size / 2 + inset))
        path.addLine(to: CGPoint(x: size / 2 - inset, y: size / 2 - inset))
        path.move(to: CGPoint(x: size / 2 - inset, y: -size / 2 + inset))
        path.addLine(to: CGPoint(x: -size / 2 + inset, y: size / 2 - inset))

        return path
    }

    // MARK: - Step Logic

    /// Perform one grid step. Returns true if obstacle should be removed.
    func step() -> Bool {
        guard !isMoving else { return false }
        guard let level = level else { return true }

        let oldCol = col
        let oldRow = row

        switch obstacleType {
        case .rolling:
            stepRolling(level: level)
        case .falling:
            stepFalling()
        }

        // Check if off-screen
        if row < 0 || row > RivetClimbConstants.rows {
            return true
        }

        // Animate if position changed
        if col != oldCol || row != oldRow {
            startMoveAnimation(from: level.worldPosition(col: oldCol, row: oldRow),
                               to: level.worldPosition(col: col, row: row))
        }

        return false
    }

    private func stepRolling(level: RivetClimbLevel) {
        let nextCol = col + direction

        // Check bounds
        if nextCol < 0 || nextCol > RivetClimbConstants.columns - 1 {
            // At edge, try to drop
            if level.isPlatform(col: col, row: row - 1) {
                row -= 1
                direction = [-1, 1].randomElement()!
            } else {
                row -= 1 // Fall off
            }
            return
        }

        // Check if on platform+ladder (potential drop-through)
        let currentCell = level.cell(col: col, row: row)
        if currentCell == .platformLadder {
            let dropChance = RivetClimbConstants.dropThroughPercent(for: runLevel)
            if Int.random(in: 1...100) <= dropChance {
                // Drop through ladder hole
                row -= 1
                return
            }
        }

        // Try to continue rolling
        if level.isPlatform(col: nextCol, row: row) {
            col = nextCol
        } else if level.isPlatform(col: col, row: row - 1) {
            // Platform edge, drop down
            row -= 1
            direction = [-1, 1].randomElement()!
        } else {
            // No platform below, continue falling
            row -= 1
        }
    }

    private func stepFalling() {
        row -= 1
    }

    // MARK: - Animation

    private func startMoveAnimation(from startPos: CGPoint, to targetPos: CGPoint) {
        moveStartPosition = startPos
        moveTargetPosition = targetPos
        moveProgress = 0
        isMoving = true
    }

    /// Update animation each frame
    func updateAnimation(deltaTime: TimeInterval) {
        guard isMoving else { return }

        moveProgress += CGFloat(deltaTime / moveAnimationDuration)

        if moveProgress >= 1.0 {
            position = moveTargetPosition
            isMoving = false
            moveProgress = 0
        } else {
            // Linear interpolation for obstacles
            position = CGPoint(
                x: moveStartPosition.x + (moveTargetPosition.x - moveStartPosition.x) * moveProgress,
                y: moveStartPosition.y + (moveTargetPosition.y - moveStartPosition.y) * moveProgress
            )
        }

        // Add rotation for rolling obstacles
        if obstacleType == .rolling {
            let rotationSpeed: CGFloat = 5.0
            zRotation += CGFloat(direction) * rotationSpeed * CGFloat(deltaTime)
        }
    }

    // MARK: - Collision

    /// Get current grid position
    var gridPosition: LevelPosition {
        LevelPosition(col: col, row: row)
    }

    /// Check if obstacle collides with player at given position
    func collidesWith(playerPosition: LevelPosition) -> Bool {
        col == playerPosition.col && row == playerPosition.row
    }

    /// Check if obstacle is off-screen and should be removed
    var isOffScreen: Bool {
        row < 0 || row > RivetClimbConstants.rows
    }
}
