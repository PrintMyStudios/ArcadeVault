import SpriteKit

// MARK: - Player State

/// The current state of the player
enum PlayerState: Equatable {
    case grounded(col: Int, row: Int)   // On platform, can walk
    case climbing(col: Int, row: Int)    // On ladder, can climb
    case falling(col: Int, row: Int)     // Descending step-by-step

    var col: Int {
        switch self {
        case .grounded(let col, _), .climbing(let col, _), .falling(let col, _):
            return col
        }
    }

    var row: Int {
        switch self {
        case .grounded(_, let row), .climbing(_, let row), .falling(_, let row):
            return row
        }
    }

    var position: LevelPosition {
        LevelPosition(col: col, row: row)
    }

    var isGrounded: Bool {
        if case .grounded = self { return true }
        return false
    }

    var isClimbing: Bool {
        if case .climbing = self { return true }
        return false
    }

    var isFalling: Bool {
        if case .falling = self { return true }
        return false
    }
}

// MARK: - Player Action

/// Actions the player can queue
enum PlayerAction {
    case walkLeft
    case walkRight
    case climbUp
    case climbDown

    var direction: RivetMoveDirection {
        switch self {
        case .walkLeft: return .left
        case .walkRight: return .right
        case .climbUp: return .up
        case .climbDown: return .down
        }
    }
}

// MARK: - Player Class

/// The player character for Rivet Climb
class RivetClimbPlayer: SKShapeNode {

    // MARK: - Properties

    /// Current player state
    private(set) var state: PlayerState

    /// Reference to level for movement checks
    weak var level: RivetClimbLevel?

    /// Queued action (max 1)
    var queuedAction: PlayerAction?

    /// Whether player is currently moving (animating between cells)
    private(set) var isMoving: Bool = false

    /// Progress through current movement (0.0 to 1.0)
    private var moveProgress: CGFloat = 0

    /// Starting world position for current move
    private var moveStartPosition: CGPoint = .zero

    /// Target world position for current move
    private var moveTargetPosition: CGPoint = .zero

    /// Duration of current move
    private var moveDuration: TimeInterval = 0

    /// Whether player is invincible
    private(set) var isInvincible: Bool = false

    /// Timer for invincibility end
    private var invincibilityTimer: TimeInterval = 0

    /// Base color for player
    private let baseColor: SKColor

    /// Player size
    private let playerSize: CGFloat

    // MARK: - Initialization

    init(color: SKColor, level: RivetClimbLevel) {
        self.baseColor = color
        self.level = level
        self.playerSize = level.tileSize.width * RivetClimbConstants.playerSizeRatio

        // Start at player start position
        let startPos = level.playerStartPosition
        self.state = .grounded(col: startPos.col, row: startPos.row)

        super.init()

        setupShape()
        setupPhysics()

        // Set initial position
        self.position = level.worldPosition(for: startPos)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupShape() {
        // Create a simple worker/climber shape (rounded rectangle body with head)
        let path = createPlayerPath()
        self.path = path
        self.fillColor = baseColor
        self.strokeColor = baseColor.withAlphaComponent(0.8)
        self.lineWidth = 2
        self.glowWidth = RivetClimbConstants.playerGlowWidth
    }

    private func createPlayerPath() -> CGPath {
        let path = CGMutablePath()

        let bodyWidth = playerSize * 0.6
        let bodyHeight = playerSize * 0.7
        let headRadius = playerSize * 0.2

        // Body (rounded rectangle)
        let bodyRect = CGRect(
            x: -bodyWidth / 2,
            y: -playerSize / 2,
            width: bodyWidth,
            height: bodyHeight
        )
        path.addRoundedRect(in: bodyRect, cornerWidth: 4, cornerHeight: 4)

        // Head (circle)
        let headCenter = CGPoint(x: 0, y: -playerSize / 2 + bodyHeight + headRadius * 0.5)
        path.addEllipse(in: CGRect(
            x: headCenter.x - headRadius,
            y: headCenter.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        ))

        return path
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: playerSize / 2)
        body.isDynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = RivetClimbConstants.playerCategory
        body.contactTestBitMask = RivetClimbConstants.collectibleCategory | RivetClimbConstants.goalCategory
        body.collisionBitMask = 0
        self.physicsBody = body
    }

    // MARK: - Update

    /// Update player each frame
    func update(deltaTime: TimeInterval) {
        // Update invincibility
        if isInvincible {
            invincibilityTimer -= deltaTime
            if invincibilityTimer <= 0 {
                endInvincibility()
            }
        }

        // Update movement animation
        if isMoving {
            updateMovement(deltaTime: deltaTime)
        } else {
            // Try to execute queued action or continue falling
            if state.isFalling {
                processFalling()
            } else if let action = queuedAction {
                queuedAction = nil
                tryAction(action)
            }
        }
    }

    // MARK: - Movement

    /// Try to perform an action
    func tryAction(_ action: PlayerAction) {
        guard !isMoving else {
            // Queue the action
            queuedAction = action
            return
        }

        guard let level = level else { return }

        let direction = action.direction

        switch state {
        case .grounded(let col, let row):
            let pos = LevelPosition(col: col, row: row)

            if direction.isHorizontal {
                // Try to walk
                if level.canWalk(from: pos, direction: direction) {
                    startWalk(from: pos, direction: direction)
                }
            } else if direction == .up {
                // Try to start climbing
                if level.canStartClimbing(from: pos) {
                    startClimb(from: pos, direction: .up)
                }
            }

        case .climbing(let col, let row):
            let pos = LevelPosition(col: col, row: row)

            if direction.isVertical {
                // Continue climbing
                if level.canClimb(from: pos, direction: direction) {
                    startClimb(from: pos, direction: direction)
                } else if direction == .up {
                    // At top of ladder, can't go higher - maybe dismount?
                } else if direction == .down && level.isPlatform(at: pos) {
                    // At bottom of ladder on platform, transition to grounded
                    state = .grounded(col: col, row: row)
                }
            } else {
                // Try to dismount
                if level.canDismount(from: pos, direction: direction) {
                    startDismount(from: pos, direction: direction)
                }
            }

        case .falling:
            // Can't act while falling
            break
        }
    }

    private func startWalk(from pos: LevelPosition, direction: RivetMoveDirection) {
        guard let level = level else { return }

        let targetCol = pos.col + direction.dc
        let targetPos = LevelPosition(col: targetCol, row: pos.row)

        // Check if target is valid platform
        if level.isPlatform(at: targetPos) {
            startMove(
                to: .grounded(col: targetCol, row: pos.row),
                duration: RivetClimbConstants.walkStepDuration
            )
        } else {
            // Walking into empty space = start falling
            state = .falling(col: targetCol, row: pos.row)
            position = level.worldPosition(for: targetPos)
        }
    }

    private func startClimb(from pos: LevelPosition, direction: RivetMoveDirection) {
        guard let level = level else { return }

        let targetRow = pos.row + direction.dr
        let targetPos = LevelPosition(col: pos.col, row: targetRow)

        // Climbing up or down
        if level.isLadder(at: targetPos) {
            startMove(
                to: .climbing(col: pos.col, row: targetRow),
                duration: RivetClimbConstants.climbStepDuration
            )
        } else if direction == .up && level.isPlatform(at: targetPos) {
            // Reached top of ladder onto platform
            startMove(
                to: .grounded(col: pos.col, row: targetRow),
                duration: RivetClimbConstants.climbStepDuration
            )
        }
    }

    private func startDismount(from pos: LevelPosition, direction: RivetMoveDirection) {
        guard let level = level else { return }

        let targetCol = pos.col + direction.dc
        let targetPos = LevelPosition(col: targetCol, row: pos.row)

        if level.isPlatform(at: targetPos) {
            startMove(
                to: .grounded(col: targetCol, row: pos.row),
                duration: RivetClimbConstants.walkStepDuration
            )
        }
    }

    private func startMove(to newState: PlayerState, duration: TimeInterval) {
        guard let level = level else { return }

        moveStartPosition = position
        moveTargetPosition = level.worldPosition(col: newState.col, row: newState.row)
        moveDuration = duration
        moveProgress = 0
        isMoving = true

        // Update state immediately
        state = newState
    }

    private func updateMovement(deltaTime: TimeInterval) {
        moveProgress += CGFloat(deltaTime / moveDuration)

        if moveProgress >= 1.0 {
            // Movement complete
            position = moveTargetPosition
            isMoving = false
            moveProgress = 0
        } else {
            // Interpolate position with easing
            let t = easeOutQuad(moveProgress)
            position = CGPoint(
                x: moveStartPosition.x + (moveTargetPosition.x - moveStartPosition.x) * t,
                y: moveStartPosition.y + (moveTargetPosition.y - moveStartPosition.y) * t
            )
        }
    }

    private func processFalling() {
        guard let level = level else { return }
        guard case .falling(let col, let row) = state else { return }

        // Check if we can land
        if row == 0 {
            // At bottom - check for platform
            if level.isPlatform(col: col, row: 0) {
                state = .grounded(col: col, row: 0)
                position = level.worldPosition(col: col, row: 0)
            } else {
                // Fell off bottom - death (scene handles this)
            }
            return
        }

        // Check platform below
        let belowRow = row - 1
        if level.isPlatform(col: col, row: belowRow) {
            // Land on platform below
            startMove(
                to: .grounded(col: col, row: belowRow),
                duration: RivetClimbConstants.fallStepDuration
            )
        } else {
            // Continue falling
            startMove(
                to: .falling(col: col, row: belowRow),
                duration: RivetClimbConstants.fallStepDuration
            )
        }
    }

    /// Easing function for smooth movement
    private func easeOutQuad(_ t: CGFloat) -> CGFloat {
        1 - (1 - t) * (1 - t)
    }

    // MARK: - Invincibility

    /// Start invincibility period
    func startInvincibility(duration: TimeInterval = RivetClimbConstants.invincibilityDuration) {
        isInvincible = true
        invincibilityTimer = duration

        // Blinking effect
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let blinkForever = SKAction.repeatForever(blink)
        run(blinkForever, withKey: "invincibilityBlink")
    }

    private func endInvincibility() {
        isInvincible = false
        invincibilityTimer = 0
        removeAction(forKey: "invincibilityBlink")
        alpha = 1.0
    }

    // MARK: - Reset

    /// Reset player to starting position
    func reset() {
        guard let level = level else { return }

        let startPos = level.playerStartPosition
        state = .grounded(col: startPos.col, row: startPos.row)
        position = level.worldPosition(for: startPos)

        isMoving = false
        moveProgress = 0
        queuedAction = nil

        endInvincibility()
        removeAllActions()
    }

    /// Move to specific position (for respawn)
    func moveTo(position: LevelPosition) {
        guard let level = level else { return }

        state = .grounded(col: position.col, row: position.row)
        self.position = level.worldPosition(for: position)
        isMoving = false
        moveProgress = 0
        queuedAction = nil
    }

    // MARK: - State Queries

    /// Get current grid position
    var gridPosition: LevelPosition {
        state.position
    }

    /// Check if player is at ground level (row 0) and not on platform
    var hasFallenOff: Bool {
        guard let level = level else { return false }
        if case .falling(let col, let row) = state {
            return row < 0 || (row == 0 && !level.isPlatform(col: col, row: 0))
        }
        return false
    }
}
