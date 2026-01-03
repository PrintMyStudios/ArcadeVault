import SpriteKit

// MARK: - Enemy State

enum EnemyState {
    case inHome         // Waiting in spawn area
    case exiting        // Moving out through door
    case scatter        // Moving to corner (patrol mode)
    case chase          // Actively pursuing player
    case frightened     // Running away (power-up active)
    case eaten          // Returning to home as eyes only
}

// MARK: - Enemy Personality

enum EnemyPersonality: CaseIterable {
    case chaser      // Directly targets player position
    case ambusher    // Targets 4 tiles ahead of player
    case patrol      // Alternates between corners
    case random      // Random valid direction at intersections
}

// MARK: - Glyph Runner Enemy

class GlyphRunnerEnemy: SKShapeNode {

    // MARK: - Identity

    let enemyId: Int
    let personality: EnemyPersonality

    // MARK: - State

    private(set) var state: EnemyState = .inHome
    private(set) var gridPosition: GridPosition
    private(set) var currentDirection: MoveDirection = .none

    // MARK: - Movement

    private var isMoving: Bool = false
    private var moveProgress: CGFloat = 0
    private var startWorldPosition: CGPoint = .zero
    private var targetWorldPosition: CGPoint = .zero
    private var moveSpeed: CGFloat

    // MARK: - Targeting

    private var scatterTarget: GridPosition
    private var homePosition: GridPosition

    // MARK: - References

    weak var maze: GlyphRunnerMaze?
    weak var targetPlayer: GlyphRunnerPlayer?

    // MARK: - Colors

    private let normalColor: SKColor
    private let frightenedColor: SKColor
    private var isFlashing: Bool = false

    // MARK: - Eyes Node (for eaten state)

    private var eyesNode: SKNode?
    private let enemySize: CGFloat

    // MARK: - Initialization

    init(id: Int, personality: EnemyPersonality, color: SKColor, frightenedColor: SKColor, maze: GlyphRunnerMaze) {
        self.enemyId = id
        self.personality = personality
        self.normalColor = color
        self.frightenedColor = frightenedColor
        self.maze = maze
        self.enemySize = maze.tileSize * GlyphRunnerConstants.enemySizeRatio
        self.moveSpeed = CGFloat(1.0 / GlyphRunnerConstants.enemyBaseMoveSpeed)

        // Get home position from maze
        let homePositions = maze.enemyHomePositions
        self.homePosition = homePositions.isEmpty ? GridPosition(col: 7, row: 10) : homePositions[id % homePositions.count]
        self.gridPosition = homePosition

        // Set scatter target (each enemy goes to different corner)
        let corners = [
            GridPosition(col: 1, row: maze.rows - 2),      // Top-left
            GridPosition(col: maze.columns - 2, row: maze.rows - 2), // Top-right
            GridPosition(col: 1, row: 1),                   // Bottom-left
            GridPosition(col: maze.columns - 2, row: 1)     // Bottom-right
        ]
        self.scatterTarget = corners[id % corners.count]

        super.init()

        setupShape()
        setupPhysics()
        setupEyes()

        // Set initial position
        self.position = maze.worldPosition(for: gridPosition)
        self.startWorldPosition = self.position
        self.targetWorldPosition = self.position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape() {
        // Create diamond/rhombus shape
        let path = createDiamondPath(size: enemySize)
        self.path = path

        self.fillColor = normalColor
        self.strokeColor = normalColor.withAlphaComponent(0.8)
        self.lineWidth = 2
        self.glowWidth = GlyphRunnerConstants.enemyGlowWidth
        self.name = "enemy"
    }

    private func createDiamondPath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let half = size / 2

        path.move(to: CGPoint(x: 0, y: half))      // Top
        path.addLine(to: CGPoint(x: half, y: 0))   // Right
        path.addLine(to: CGPoint(x: 0, y: -half))  // Bottom
        path.addLine(to: CGPoint(x: -half, y: 0))  // Left
        path.closeSubpath()

        return path
    }

    private func setupPhysics() {
        let physicsRadius = enemySize * 0.4
        physicsBody = SKPhysicsBody(circleOfRadius: physicsRadius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = GlyphRunnerConstants.enemyCategory
        physicsBody?.contactTestBitMask = GlyphRunnerConstants.playerCategory
        physicsBody?.collisionBitMask = 0
    }

    private func setupEyes() {
        let eyeContainer = SKNode()

        let eyeSize: CGFloat = enemySize * 0.15
        let eyeSpacing: CGFloat = enemySize * 0.25

        // Left eye
        let leftEye = SKShapeNode(circleOfRadius: eyeSize)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -eyeSpacing, y: eyeSize)

        let leftPupil = SKShapeNode(circleOfRadius: eyeSize * 0.5)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: eyeSize * 0.3, y: 0)
        leftEye.addChild(leftPupil)

        // Right eye
        let rightEye = SKShapeNode(circleOfRadius: eyeSize)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: eyeSpacing, y: eyeSize)

        let rightPupil = SKShapeNode(circleOfRadius: eyeSize * 0.5)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: eyeSize * 0.3, y: 0)
        rightEye.addChild(rightPupil)

        eyeContainer.addChild(leftEye)
        eyeContainer.addChild(rightEye)
        eyeContainer.zPosition = 1

        addChild(eyeContainer)
        eyesNode = eyeContainer
    }

    // MARK: - State Changes

    func release() {
        guard state == .inHome else { return }
        state = .exiting
        currentDirection = .up
    }

    func frighten() {
        guard state != .eaten && state != .inHome else { return }
        state = .frightened
        updateVisuals()
        reverseDirection()
    }

    func endFrighten() {
        guard state == .frightened else { return }
        state = .scatter
        isFlashing = false
        updateVisuals()
    }

    func eaten() {
        state = .eaten
        updateVisuals()
        // Speed up when returning home
        moveSpeed = CGFloat(1.0 / GlyphRunnerConstants.enemyBaseMoveSpeed) * 2.0
    }

    func reset() {
        state = .inHome
        gridPosition = homePosition
        guard let maze = maze else { return }
        position = maze.worldPosition(for: gridPosition)
        startWorldPosition = position
        targetWorldPosition = position
        currentDirection = .none
        isMoving = false
        moveProgress = 0
        isFlashing = false
        moveSpeed = CGFloat(1.0 / GlyphRunnerConstants.enemyBaseMoveSpeed)
        updateVisuals()
    }

    func reverseDirection() {
        currentDirection = currentDirection.opposite
    }

    func flashWarning() {
        guard !isFlashing && state == .frightened else { return }
        isFlashing = true

        let flash = SKAction.sequence([
            SKAction.run { [weak self] in self?.fillColor = .white },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { [weak self] in self?.fillColor = self?.frightenedColor ?? .blue },
            SKAction.wait(forDuration: 0.15)
        ])
        run(SKAction.repeatForever(flash), withKey: "flash")
    }

    func increaseSpeed(forLevel level: Int) {
        let speedIncrease = TimeInterval(level - 1) * GlyphRunnerConstants.enemySpeedIncreasePerLevel
        let newSpeed = max(
            GlyphRunnerConstants.minEnemyMoveSpeed,
            GlyphRunnerConstants.enemyBaseMoveSpeed - speedIncrease
        )
        moveSpeed = CGFloat(1.0 / newSpeed)
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval, isScatterMode: Bool) {
        guard let maze = maze else { return }

        switch state {
        case .inHome:
            // Bobbing animation in home
            break

        case .exiting:
            updateExiting(deltaTime: deltaTime, maze: maze)

        case .scatter, .chase, .frightened:
            updateMovement(deltaTime: deltaTime, maze: maze, isScatterMode: isScatterMode)

        case .eaten:
            updateReturningHome(deltaTime: deltaTime, maze: maze)
        }
    }

    private func updateExiting(deltaTime: TimeInterval, maze: GlyphRunnerMaze) {
        if isMoving {
            moveProgress += CGFloat(deltaTime) * moveSpeed

            if moveProgress >= 1.0 {
                completeMove(maze: maze)

                // Check if we've exited the home
                if !maze.isEnemyHome(at: gridPosition) {
                    state = .scatter
                }
            } else {
                updatePosition()
            }
        } else {
            // Move toward the door
            if maze.canMove(from: gridPosition, direction: .up) {
                startMove(in: .up, maze: maze)
            } else {
                // Find path to door
                let door = maze.enemyDoorPosition
                let direction = chooseDirectionToward(door, maze: maze)
                if direction != .none {
                    startMove(in: direction, maze: maze)
                }
            }
        }
    }

    private func updateMovement(deltaTime: TimeInterval, maze: GlyphRunnerMaze, isScatterMode: Bool) {
        if isMoving {
            moveProgress += CGFloat(deltaTime) * moveSpeed

            if moveProgress >= 1.0 {
                completeMove(maze: maze)
                // Choose next direction
                let target = calculateTarget(isScatterMode: isScatterMode)
                let direction = chooseNextDirection(toward: target, maze: maze)
                if direction != .none {
                    startMove(in: direction, maze: maze)
                }
            } else {
                updatePosition()
            }
        } else {
            // Start moving
            let target = calculateTarget(isScatterMode: isScatterMode)
            let direction = chooseNextDirection(toward: target, maze: maze)
            if direction != .none {
                startMove(in: direction, maze: maze)
            }
        }
    }

    private func updateReturningHome(deltaTime: TimeInterval, maze: GlyphRunnerMaze) {
        if isMoving {
            moveProgress += CGFloat(deltaTime) * moveSpeed

            if moveProgress >= 1.0 {
                completeMove(maze: maze)

                // Check if we've reached home
                if maze.isEnemyHome(at: gridPosition) {
                    reset()
                    return
                }

                // Continue toward home
                let direction = chooseDirectionToward(homePosition, maze: maze)
                if direction != .none {
                    startMove(in: direction, maze: maze)
                }
            } else {
                updatePosition()
            }
        } else {
            let direction = chooseDirectionToward(homePosition, maze: maze)
            if direction != .none {
                startMove(in: direction, maze: maze)
            }
        }
    }

    // MARK: - Movement Helpers

    private func startMove(in direction: MoveDirection, maze: GlyphRunnerMaze) {
        let newGridPos = gridPosition.offset(by: direction)
        targetWorldPosition = maze.worldPosition(for: newGridPos)
        startWorldPosition = position
        moveProgress = 0
        isMoving = true
        currentDirection = direction
        gridPosition = newGridPos
    }

    private func completeMove(maze: GlyphRunnerMaze) {
        position = targetWorldPosition
        startWorldPosition = targetWorldPosition
        moveProgress = 0
        isMoving = false
    }

    private func updatePosition() {
        let t = easeInOutQuad(moveProgress)
        position = CGPoint(
            x: startWorldPosition.x + (targetWorldPosition.x - startWorldPosition.x) * t,
            y: startWorldPosition.y + (targetWorldPosition.y - startWorldPosition.y) * t
        )
    }

    private func easeInOutQuad(_ t: CGFloat) -> CGFloat {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    // MARK: - AI Targeting

    private func calculateTarget(isScatterMode: Bool) -> GridPosition {
        guard let player = targetPlayer else { return scatterTarget }

        if state == .frightened {
            // Run away from player - pick random direction
            return GridPosition(col: Int.random(in: 0..<(maze?.columns ?? 15)),
                              row: Int.random(in: 0..<(maze?.rows ?? 21)))
        }

        if isScatterMode {
            return scatterTarget
        }

        // Chase mode - behavior varies by personality
        switch personality {
        case .chaser:
            return player.gridPosition

        case .ambusher:
            return player.gridPosition.offset(by: player.currentDirection, distance: 4)

        case .patrol:
            // Alternate between corners based on distance
            let distToScatter = gridPosition.distance(to: scatterTarget)
            if distToScatter < 3 {
                // Switch to opposite corner
                let cols = maze?.columns ?? 15
                let rows = maze?.rows ?? 21
                return GridPosition(
                    col: cols - 1 - scatterTarget.col,
                    row: rows - 1 - scatterTarget.row
                )
            }
            return scatterTarget

        case .random:
            return player.gridPosition // Will pick randomly at intersections
        }
    }

    private func chooseNextDirection(toward target: GridPosition, maze: GlyphRunnerMaze) -> MoveDirection {
        // Get valid directions (excluding reverse)
        let validDirections = maze.validDirections(from: gridPosition, excluding: currentDirection.opposite)

        guard !validDirections.isEmpty else {
            // Must reverse if no other option
            return currentDirection.opposite
        }

        if personality == .random && state != .frightened {
            // Random enemy picks randomly at intersections
            if maze.isIntersection(at: gridPosition) {
                return validDirections.randomElement() ?? .none
            }
        }

        // Choose direction that minimizes distance to target
        return validDirections.min { dir1, dir2 in
            let pos1 = gridPosition.offset(by: dir1)
            let pos2 = gridPosition.offset(by: dir2)
            return pos1.distance(to: target) < pos2.distance(to: target)
        } ?? validDirections.first ?? .none
    }

    private func chooseDirectionToward(_ target: GridPosition, maze: GlyphRunnerMaze) -> MoveDirection {
        let validDirections = maze.validDirections(from: gridPosition, excluding: .none)

        return validDirections.min { dir1, dir2 in
            let pos1 = gridPosition.offset(by: dir1)
            let pos2 = gridPosition.offset(by: dir2)
            return pos1.distance(to: target) < pos2.distance(to: target)
        } ?? .none
    }

    // MARK: - Visuals

    private func updateVisuals() {
        removeAction(forKey: "flash")

        switch state {
        case .frightened:
            fillColor = frightenedColor
            strokeColor = frightenedColor.withAlphaComponent(0.8)
            alpha = 1.0
            eyesNode?.isHidden = false

        case .eaten:
            fillColor = .clear
            strokeColor = .clear
            alpha = 0.6
            eyesNode?.isHidden = false

        default:
            fillColor = normalColor
            strokeColor = normalColor.withAlphaComponent(0.8)
            alpha = 1.0
            eyesNode?.isHidden = false
        }
    }
}
