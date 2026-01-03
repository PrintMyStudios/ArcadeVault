import SpriteKit
import UIKit

// MARK: - Game Phase

private enum GamePhase {
    case playing
    case levelComplete
    case dying
    case gameOver
}

// MARK: - Scene

/// Main gameplay scene for Rivet Climb
class RivetClimbScene: SKScene, SKPhysicsContactDelegate, RestartableScene {

    // MARK: - Delegate

    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Game Objects

    private var level: RivetClimbLevel!
    private var levelNode: SKNode?
    private var player: RivetClimbPlayer!
    private var obstacles: [RivetClimbObstacle] = []
    private var collectibleNodes: [LevelPosition: SKShapeNode] = [:]
    private var goalNode: SKShapeNode?

    // MARK: - Game State

    private var score: Int = 0
    private var runLevel: Int = 1
    private var lives: Int = RivetClimbConstants.startingLives
    private var gamePhase: GamePhase = .playing
    private var collectedCount: Int = 0
    private var totalCollectibles: Int = 0
    private var consecutiveRivets: Int = 0  // For streak bonus
    private var levelTimeRemaining: TimeInterval = RivetClimbConstants.levelTimeLimit

    // MARK: - Timing

    private var lastUpdateTime: TimeInterval = 0
    private var obstacleStepAccumulator: TimeInterval = 0
    private var nextSpawnTime: TimeInterval = 0
    private var holdStartTime: TimeInterval = 0
    private var lastHoldRepeatTime: TimeInterval = 0
    private var isHolding: Bool = false
    private var holdAction: PlayerAction?

    // MARK: - Theme Colors (cached)

    private var bgColor: SKColor = .black
    private var platformColor: SKColor = .gray
    private var ladderColor: SKColor = .orange
    private var playerColor: SKColor = .cyan
    private var obstacleColor: SKColor = .red
    private var collectibleColor: SKColor = .yellow
    private var goalColor: SKColor = .green

    // MARK: - Gesture Recognizers

    private var swipeRecognizers: [UISwipeGestureRecognizer] = []
    private var tapRecognizer: UITapGestureRecognizer?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        cacheThemeColors()
        setupPhysics()
        setupLevel()
        setupPlayer()
        setupCollectibles()
        installGestureRecognizers(on: view)

        // Initialize spawn timer
        nextSpawnTime = RivetClimbConstants.spawnInterval(for: runLevel)

        // Report initial score
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }

    override func willMove(from view: SKView) {
        removeGestureRecognizers(from: view)
    }

    override func update(_ currentTime: TimeInterval) {
        guard gamePhase == .playing else { return }

        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update player
        player.update(deltaTime: deltaTime)

        // Check if player fell off
        if player.hasFallenOff {
            playerDied()
            return
        }

        // Update obstacle animations
        for obstacle in obstacles {
            obstacle.updateAnimation(deltaTime: deltaTime)
        }

        // Fixed tick for obstacle stepping
        obstacleStepAccumulator += deltaTime
        if obstacleStepAccumulator >= RivetClimbConstants.obstacleStepInterval {
            obstacleStepAccumulator -= RivetClimbConstants.obstacleStepInterval
            stepAllObstacles()
            checkObstacleCollisions()
        }

        // Spawn obstacles
        nextSpawnTime -= deltaTime
        if nextSpawnTime <= 0 {
            spawnObstacle()
            nextSpawnTime = RivetClimbConstants.spawnInterval(for: runLevel)
        }

        // Update level timer
        levelTimeRemaining -= deltaTime
        if levelTimeRemaining <= 0 {
            levelTimeRemaining = 0
            // Time's up - not necessarily game over, just no time bonus
        }

        // Handle hold-to-repeat
        if isHolding, let action = holdAction {
            let holdDuration = currentTime - holdStartTime
            if holdDuration >= RivetClimbConstants.holdRepeatDelay {
                if currentTime - lastHoldRepeatTime >= RivetClimbConstants.holdRepeatInterval {
                    player.tryAction(action)
                    lastHoldRepeatTime = currentTime
                }
            }
        }

        // Check danger bonus (obstacle within 1 cell)
        checkDangerBonus()
    }

    // MARK: - Setup

    private func cacheThemeColors() {
        let palette = ThemeManager.shared.currentTheme.palette
        bgColor = SKColor(palette.background)
        platformColor = SKColor(palette.foreground)
        ladderColor = SKColor(palette.accent)
        playerColor = SKColor(palette.accent)
        obstacleColor = SKColor(palette.danger)
        collectibleColor = SKColor(palette.success)
        goalColor = SKColor(palette.accent)

        backgroundColor = bgColor
    }

    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero  // We handle gravity via grid movement
    }

    private func setupLevel() {
        level = RivetClimbLevel()
        level.configureForScene(size: size)
        level.loadLevel(index: (runLevel - 1) % 3)

        // Create visual representation
        levelNode?.removeFromParent()
        levelNode = level.createLevelNode(
            platformColor: platformColor,
            ladderColor: ladderColor,
            goalColor: goalColor
        )
        addChild(levelNode!)
    }

    private func setupPlayer() {
        player?.removeFromParent()
        player = RivetClimbPlayer(color: playerColor, level: level)
        addChild(player)
    }

    private func setupCollectibles() {
        // Remove existing
        for (_, node) in collectibleNodes {
            node.removeFromParent()
        }
        collectibleNodes.removeAll()

        // Get collectible positions (use variant based on run level)
        let variant = (runLevel - 1) % 3
        let positions = RivetClimbLevel.collectibleVariant(for: level.currentLayoutIndex, variant: variant)

        totalCollectibles = positions.count
        collectedCount = 0

        for pos in positions {
            let node = createCollectibleNode()
            node.position = level.worldPosition(for: pos)
            addChild(node)
            collectibleNodes[pos] = node
        }
    }

    private func createCollectibleNode() -> SKShapeNode {
        let collectibleSize = level.tileSize.width * RivetClimbConstants.collectibleSizeRatio

        // Rivet shape (hexagon with center hole)
        let path = CGMutablePath()
        let radius = collectibleSize / 2

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

        // Center hole
        let holeRadius = radius * 0.3
        path.addEllipse(in: CGRect(x: -holeRadius, y: -holeRadius, width: holeRadius * 2, height: holeRadius * 2))

        let node = SKShapeNode(path: path)
        node.fillColor = collectibleColor
        node.strokeColor = collectibleColor.withAlphaComponent(0.8)
        node.lineWidth = 1
        node.glowWidth = RivetClimbConstants.collectibleGlowWidth

        // Physics for collection detection
        let body = SKPhysicsBody(circleOfRadius: collectibleSize / 2)
        body.isDynamic = false
        body.categoryBitMask = RivetClimbConstants.collectibleCategory
        body.contactTestBitMask = RivetClimbConstants.playerCategory
        body.collisionBitMask = 0
        node.physicsBody = body

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        node.run(SKAction.repeatForever(pulse))

        return node
    }

    // MARK: - Gesture Recognizers

    private func installGestureRecognizers(on view: SKView) {
        // Swipe recognizers for climbing
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        for direction in directions {
            let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            recognizer.direction = direction
            view.addGestureRecognizer(recognizer)
            swipeRecognizers.append(recognizer)
        }

        // Tap recognizer for walking (tap zones)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        tapRecognizer = tap
    }

    private func removeGestureRecognizers(from view: SKView) {
        for recognizer in swipeRecognizers {
            view.removeGestureRecognizer(recognizer)
        }
        swipeRecognizers.removeAll()

        if let tap = tapRecognizer {
            view.removeGestureRecognizer(tap)
            tapRecognizer = nil
        }
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard gamePhase == .playing else { return }

        let action: PlayerAction
        switch gesture.direction {
        case .up:
            action = .climbUp
        case .down:
            action = .climbDown
        case .left:
            action = .walkLeft
        case .right:
            action = .walkRight
        default:
            return
        }

        player.tryAction(action)
        gameDelegate?.gameScene(self, requestHaptic: .light)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gamePhase == .playing else { return }
        guard let view = self.view else { return }

        let location = gesture.location(in: view)
        let midX = view.bounds.width / 2

        // Tap zones: left half = walk left, right half = walk right
        let action: PlayerAction = location.x < midX ? .walkLeft : .walkRight
        player.tryAction(action)
        gameDelegate?.gameScene(self, requestHaptic: .light)
    }

    // MARK: - Touch Handling (for hold-to-repeat)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gamePhase == .playing else { return }
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let midX = size.width / 2

        holdAction = location.x < midX ? .walkLeft : .walkRight
        holdStartTime = lastUpdateTime
        lastHoldRepeatTime = 0
        isHolding = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHolding = false
        holdAction = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHolding = false
        holdAction = nil
    }

    // MARK: - Obstacles

    private func spawnObstacle() {
        guard obstacles.count < RivetClimbConstants.maxObstacles else { return }

        // Get active spawn points based on difficulty
        let maxActive = RivetClimbConstants.activeSpawnPoints(for: runLevel)
        let activeSpawns = Array(level.spawnPositions.prefix(maxActive))

        guard !activeSpawns.isEmpty else { return }

        // Pick random spawn point
        guard let spawnPos = activeSpawns.randomElement() else { return }

        // Safety check: don't spawn if player is nearby
        if spawnPos.distance(to: player.gridPosition) <= RivetClimbConstants.spawnSafetyBuffer {
            return
        }

        // Create obstacle
        let type = ObstacleType.random(for: runLevel)
        let obstacle = RivetClimbObstacle(
            type: type,
            color: obstacleColor,
            level: level,
            spawnPosition: spawnPos,
            runLevel: runLevel
        )
        addChild(obstacle)
        obstacles.append(obstacle)
    }

    private func stepAllObstacles() {
        var toRemove: [Int] = []

        for (index, obstacle) in obstacles.enumerated() {
            let shouldRemove = obstacle.step()
            if shouldRemove || obstacle.isOffScreen {
                toRemove.append(index)
            }
        }

        // Remove off-screen obstacles (reverse order to maintain indices)
        for index in toRemove.reversed() {
            obstacles[index].removeFromParent()
            obstacles.remove(at: index)
        }
    }

    private func checkObstacleCollisions() {
        guard !player.isInvincible else { return }

        let playerPos = player.gridPosition

        for obstacle in obstacles {
            if obstacle.collidesWith(playerPosition: playerPos) {
                playerDied()
                return
            }
        }
    }

    private func checkDangerBonus() {
        let playerPos = player.gridPosition

        for obstacle in obstacles {
            let distance = obstacle.gridPosition.distance(to: playerPos)
            if distance == 1 {
                // Obstacle passed within 1 cell - danger bonus!
                addScore(RivetClimbConstants.dangerBonus, for: .dangerBonus)
            }
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == RivetClimbConstants.playerCategory | RivetClimbConstants.collectibleCategory {
            handleCollectibleContact(contact)
        } else if collision == RivetClimbConstants.playerCategory | RivetClimbConstants.goalCategory {
            handleGoalContact()
        }
    }

    private func handleCollectibleContact(_ contact: SKPhysicsContact) {
        // Find which body is the collectible
        let collectibleBody = contact.bodyA.categoryBitMask == RivetClimbConstants.collectibleCategory
            ? contact.bodyA : contact.bodyB

        guard let collectibleNode = collectibleBody.node as? SKShapeNode else { return }

        // Find position in dictionary
        var collectedPos: LevelPosition?
        for (pos, node) in collectibleNodes where node === collectibleNode {
            collectedPos = pos
            break
        }

        guard let pos = collectedPos else { return }

        // Remove from dictionary
        collectibleNodes.removeValue(forKey: pos)

        // Animate collection
        let group = SKAction.group([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.scale(to: 1.5, duration: 0.2)
        ])
        collectibleNode.run(SKAction.sequence([group, SKAction.removeFromParent()]))

        // Update score
        collectedCount += 1
        consecutiveRivets += 1

        let streakBonus = (consecutiveRivets - 1) * RivetClimbConstants.streakBonus
        addScore(RivetClimbConstants.rivetPoints + streakBonus, for: .collect)

        // Check if all collected
        if collectedCount >= totalCollectibles {
            addScore(RivetClimbConstants.allRivetsBonus, for: .collect)
        }
    }

    private func handleGoalContact() {
        guard gamePhase == .playing else { return }
        levelComplete()
    }

    // MARK: - Scoring

    private enum ScoreReason {
        case collect
        case levelComplete
        case timeBonus
        case dangerBonus
    }

    private func addScore(_ points: Int, for reason: ScoreReason) {
        score += points
        gameDelegate?.gameScene(self, didUpdateScore: score)

        switch reason {
        case .collect:
            gameDelegate?.gameScene(self, requestSound: .collect)
            gameDelegate?.gameScene(self, requestHaptic: .medium)
        case .levelComplete:
            gameDelegate?.gameScene(self, requestSound: .waveComplete)
            gameDelegate?.gameScene(self, requestHaptic: .heavy)
        case .timeBonus, .dangerBonus:
            break  // No extra feedback
        }
    }

    // MARK: - Player Death

    private func playerDied() {
        guard gamePhase == .playing else { return }

        gamePhase = .dying
        consecutiveRivets = 0
        lives -= 1

        gameDelegate?.gameScene(self, requestSound: .hit)
        gameDelegate?.gameScene(self, requestHaptic: .heavy)

        // Flash effect
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        player.run(SKAction.repeat(flash, count: 3)) { [weak self] in
            self?.afterDeathAnimation()
        }
    }

    private func afterDeathAnimation() {
        if lives > 0 {
            respawn()
        } else {
            gameOver()
        }
    }

    private func respawn() {
        // Move player to start
        player.reset()
        player.startInvincibility()

        // Clear nearby obstacles
        clearNearbyObstacles()

        gamePhase = .playing
    }

    private func clearNearbyObstacles() {
        let playerPos = player.gridPosition
        let clearRadius = RivetClimbConstants.respawnClearRadius

        var toRemove: [Int] = []
        for (index, obstacle) in obstacles.enumerated() {
            if obstacle.gridPosition.distance(to: playerPos) <= clearRadius {
                toRemove.append(index)
            }
        }

        for index in toRemove.reversed() {
            obstacles[index].run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
            obstacles.remove(at: index)
        }
    }

    // MARK: - Level Complete

    private func levelComplete() {
        gamePhase = .levelComplete

        // Calculate bonuses
        let levelBonus = RivetClimbConstants.levelCompleteBasePoints * runLevel
        let timeBonus = Int(levelTimeRemaining) * RivetClimbConstants.timeBonus

        addScore(levelBonus, for: .levelComplete)
        if timeBonus > 0 {
            addScore(timeBonus, for: .timeBonus)
        }

        // Show level complete effect
        let flash = SKShapeNode(rectOf: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.fillColor = goalColor.withAlphaComponent(0.3)
        flash.strokeColor = .clear
        flash.zPosition = 100
        addChild(flash)

        let fadeSequence = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.2),
            SKAction.fadeAlpha(to: 0, duration: 0.3),
            SKAction.removeFromParent()
        ])

        flash.run(fadeSequence) { [weak self] in
            self?.startNextLevel()
        }
    }

    private func startNextLevel() {
        runLevel += 1

        // Clear obstacles
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()

        // Reset timers
        levelTimeRemaining = RivetClimbConstants.levelTimeLimit
        obstacleStepAccumulator = 0
        nextSpawnTime = RivetClimbConstants.spawnInterval(for: runLevel)

        // Setup new level
        setupLevel()
        setupPlayer()
        setupCollectibles()

        gamePhase = .playing
    }

    // MARK: - Game Over

    private func gameOver() {
        gamePhase = .gameOver

        // Screen flash
        let flash = SKShapeNode(rectOf: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.fillColor = obstacleColor.withAlphaComponent(0.5)
        flash.strokeColor = .clear
        flash.zPosition = 100
        addChild(flash)

        let flashSequence = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.1),
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 0, duration: 0.3),
            SKAction.removeFromParent()
        ])

        flash.run(flashSequence) { [weak self] in
            guard let self = self else { return }
            self.gameDelegate?.gameScene(self, requestSound: .gameOver)
            self.gameDelegate?.gameSceneDidEnd(self, finalScore: self.score)
        }
    }

    // MARK: - Restart

    func restartGame() {
        // Remove all game objects
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()

        for (_, node) in collectibleNodes {
            node.removeFromParent()
        }
        collectibleNodes.removeAll()

        levelNode?.removeFromParent()
        player?.removeFromParent()

        // Reset state
        score = 0
        runLevel = 1
        lives = RivetClimbConstants.startingLives
        gamePhase = .playing
        consecutiveRivets = 0
        levelTimeRemaining = RivetClimbConstants.levelTimeLimit
        lastUpdateTime = 0
        obstacleStepAccumulator = 0

        // Re-cache colors (theme might have changed)
        cacheThemeColors()

        // Setup fresh
        setupLevel()
        setupPlayer()
        setupCollectibles()

        nextSpawnTime = RivetClimbConstants.spawnInterval(for: runLevel)

        gameDelegate?.gameScene(self, didUpdateScore: 0)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }
}
