import SpriteKit

class GlyphRunnerPlayer: SKShapeNode {

    // MARK: - Grid State

    private(set) var gridPosition: GridPosition
    private(set) var currentDirection: MoveDirection = .none
    var queuedDirection: MoveDirection = .none

    // MARK: - Movement State

    private var isMoving: Bool = false
    private var moveProgress: CGFloat = 0
    private var startWorldPosition: CGPoint = .zero
    private var targetWorldPosition: CGPoint = .zero
    private let moveSpeed: CGFloat

    // MARK: - References

    weak var maze: GlyphRunnerMaze?
    private let playerSize: CGFloat

    // MARK: - Initialization

    init(color: SKColor, maze: GlyphRunnerMaze) {
        self.maze = maze
        self.gridPosition = maze.playerStartPosition
        self.playerSize = maze.tileSize * GlyphRunnerConstants.playerSizeRatio
        self.moveSpeed = CGFloat(1.0 / GlyphRunnerConstants.playerMoveSpeed)

        super.init()

        setupShape(color: color)
        setupPhysics()

        // Set initial position
        self.position = maze.worldPosition(for: gridPosition)
        self.startWorldPosition = self.position
        self.targetWorldPosition = self.position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape(color: SKColor) {
        // Create hexagon path
        let path = createHexagonPath(size: playerSize)
        self.path = path

        self.fillColor = color
        self.strokeColor = color.withAlphaComponent(0.8)
        self.lineWidth = 2
        self.glowWidth = GlyphRunnerConstants.playerGlowWidth
        self.name = "player"
    }

    private func createHexagonPath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let radius = size / 2
        let angleOffset = CGFloat.pi / 6 // Start at 30 degrees for pointy-top hexagon

        for i in 0..<6 {
            let angle = angleOffset + CGFloat(i) * (.pi / 3)
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

    private func setupPhysics() {
        let physicsRadius = playerSize * 0.4
        physicsBody = SKPhysicsBody(circleOfRadius: physicsRadius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = GlyphRunnerConstants.playerCategory
        physicsBody?.contactTestBitMask = GlyphRunnerConstants.glyphCategory |
                                          GlyphRunnerConstants.powerUpCategory |
                                          GlyphRunnerConstants.enemyCategory
        physicsBody?.collisionBitMask = 0 // Grid handles collisions
    }

    // MARK: - Input

    func setDirection(_ direction: MoveDirection) {
        guard direction != .none else { return }
        queuedDirection = direction
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        guard let maze = maze else { return }

        if isMoving {
            // Continue current movement
            moveProgress += CGFloat(deltaTime) * moveSpeed

            if moveProgress >= 1.0 {
                // Movement complete
                completeMove()
                // Immediately try to continue or change direction
                tryStartMove(maze: maze)
            } else {
                // Interpolate position
                updatePosition()
            }
        } else {
            // Not moving, try to start
            tryStartMove(maze: maze)
        }
    }

    private func tryStartMove(maze: GlyphRunnerMaze) {
        // First, check if queued direction is valid
        if queuedDirection != .none && maze.canMove(from: gridPosition, direction: queuedDirection) {
            startMove(in: queuedDirection)
            currentDirection = queuedDirection
            queuedDirection = .none
            return
        }

        // Otherwise, continue in current direction if valid
        if currentDirection != .none && maze.canMove(from: gridPosition, direction: currentDirection) {
            startMove(in: currentDirection)
            return
        }

        // Can't move in any direction
        currentDirection = .none
    }

    private func startMove(in direction: MoveDirection) {
        guard let maze = maze else { return }

        let newGridPos = gridPosition.offset(by: direction)
        targetWorldPosition = maze.worldPosition(for: newGridPos)
        startWorldPosition = position
        moveProgress = 0
        isMoving = true

        // Update grid position immediately for collision detection
        gridPosition = newGridPos

        // Rotate to face direction
        let targetRotation = direction.rotation
        let rotateAction = SKAction.rotate(toAngle: targetRotation, duration: 0.05, shortestUnitArc: true)
        run(rotateAction)
    }

    private func completeMove() {
        guard let maze = maze else { return }
        position = targetWorldPosition
        startWorldPosition = targetWorldPosition
        moveProgress = 0
        isMoving = false
    }

    private func updatePosition() {
        // Smooth interpolation using ease-out curve
        let t = easeOutQuad(moveProgress)
        position = CGPoint(
            x: startWorldPosition.x + (targetWorldPosition.x - startWorldPosition.x) * t,
            y: startWorldPosition.y + (targetWorldPosition.y - startWorldPosition.y) * t
        )
    }

    private func easeOutQuad(_ t: CGFloat) -> CGFloat {
        1 - (1 - t) * (1 - t)
    }

    // MARK: - Reset

    func resetToStart() {
        guard let maze = maze else { return }

        gridPosition = maze.playerStartPosition
        position = maze.worldPosition(for: gridPosition)
        startWorldPosition = position
        targetWorldPosition = position
        currentDirection = .none
        queuedDirection = .none
        isMoving = false
        moveProgress = 0
        zRotation = 0
    }

    // MARK: - State

    var isAtTileCenter: Bool {
        !isMoving
    }
}
