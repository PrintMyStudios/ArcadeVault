import SpriteKit

class GlyphRunnerScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Delegate

    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Game Objects

    private var maze: GlyphRunnerMaze!
    private var player: GlyphRunnerPlayer!
    private var enemies: [GlyphRunnerEnemy] = []
    private var glyphNodes: [GridPosition: SKShapeNode] = [:]
    private var powerUpNodes: [GridPosition: SKShapeNode] = [:]

    // MARK: - Game State

    private var score: Int = 0
    private var level: Int = 1
    private var lives: Int = GlyphRunnerConstants.startingLives
    private var glyphsRemaining: Int = 0
    private var isGameActive: Bool = true
    private var isPowerUpActive: Bool = false
    private var consecutiveEnemiesEaten: Int = 0

    // MARK: - Timing

    private var lastUpdateTime: TimeInterval = 0
    private var powerUpTimer: TimeInterval = 0
    private var enemyReleaseTimer: TimeInterval = 0
    private var enemiesReleased: Int = 0
    private var scatterChaseTimer: TimeInterval = 0
    private var isScatterMode: Bool = true

    // MARK: - Theme Colors (cached)

    private var backgroundColor_: SKColor = .black
    private var wallColor: SKColor = .gray
    private var playerColor: SKColor = .cyan
    private var enemyColor: SKColor = .red
    private var glyphColor: SKColor = .yellow
    private var powerUpColor: SKColor = .green
    private var frightenedColor: SKColor = .blue

    // MARK: - Swipe Gesture Recognizers

    private var swipeRecognizers: [UISwipeGestureRecognizer] = []

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        cacheThemeColors()
        setupPhysics()
        setupMaze()
        setupPlayer()
        setupGlyphs()
        setupPowerUps()
        setupEnemies()
        setupSwipeGestures()

        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }

    override func willMove(from view: SKView) {
        // Remove gesture recognizers
        for recognizer in swipeRecognizers {
            view.removeGestureRecognizer(recognizer)
        }
        swipeRecognizers.removeAll()
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        player.update(deltaTime: deltaTime)
        updateEnemies(deltaTime: deltaTime)
        updatePowerUpState(deltaTime: deltaTime)
        updateScatterChaseMode(deltaTime: deltaTime)
    }

    // MARK: - Setup

    private func cacheThemeColors() {
        let palette = ThemeManager.shared.currentTheme.palette

        backgroundColor_ = skColor(from: palette.background)
        wallColor = skColor(from: palette.foregroundSecondary)
        playerColor = skColor(from: palette.accent)
        enemyColor = skColor(from: palette.danger)
        glyphColor = skColor(from: palette.accentSecondary)
        powerUpColor = skColor(from: palette.success)
        frightenedColor = skColor(from: palette.warning)

        backgroundColor = backgroundColor_
    }

    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }

    private func setupMaze() {
        maze = GlyphRunnerMaze()
        maze.calculateTileSize(for: size)

        let mazeNode = maze.createMazeNode(wallColor: wallColor, backgroundColor: backgroundColor_)
        addChild(mazeNode)
    }

    private func setupPlayer() {
        player = GlyphRunnerPlayer(color: playerColor, maze: maze)
        addChild(player)
    }

    private func setupGlyphs() {
        glyphNodes.removeAll()
        glyphsRemaining = 0

        for position in maze.glyphPositions {
            let glyphNode = createGlyphNode(at: position)
            glyphNodes[position] = glyphNode
            addChild(glyphNode)
            glyphsRemaining += 1
        }
    }

    private func createGlyphNode(at position: GridPosition) -> SKShapeNode {
        let size = maze.tileSize * GlyphRunnerConstants.glyphSizeRatio
        let glyphNode = SKShapeNode(circleOfRadius: size)
        glyphNode.fillColor = glyphColor
        glyphNode.strokeColor = glyphColor.withAlphaComponent(0.6)
        glyphNode.lineWidth = 1
        glyphNode.glowWidth = GlyphRunnerConstants.glyphGlowWidth
        glyphNode.position = maze.worldPosition(for: position)
        glyphNode.name = "glyph"

        // Physics
        glyphNode.physicsBody = SKPhysicsBody(circleOfRadius: size)
        glyphNode.physicsBody?.isDynamic = false
        glyphNode.physicsBody?.categoryBitMask = GlyphRunnerConstants.glyphCategory
        glyphNode.physicsBody?.contactTestBitMask = GlyphRunnerConstants.playerCategory
        glyphNode.physicsBody?.collisionBitMask = 0

        return glyphNode
    }

    private func setupPowerUps() {
        powerUpNodes.removeAll()

        for position in maze.powerUpPositions {
            let powerUpNode = createPowerUpNode(at: position)
            powerUpNodes[position] = powerUpNode
            addChild(powerUpNode)
        }
    }

    private func createPowerUpNode(at position: GridPosition) -> SKShapeNode {
        let size = maze.tileSize * GlyphRunnerConstants.powerGlyphSizeRatio
        let powerUpNode = SKShapeNode(circleOfRadius: size)
        powerUpNode.fillColor = powerUpColor
        powerUpNode.strokeColor = powerUpColor.withAlphaComponent(0.6)
        powerUpNode.lineWidth = 2
        powerUpNode.glowWidth = GlyphRunnerConstants.glyphGlowWidth * 2
        powerUpNode.position = maze.worldPosition(for: position)
        powerUpNode.name = "powerUp"

        // Physics
        powerUpNode.physicsBody = SKPhysicsBody(circleOfRadius: size)
        powerUpNode.physicsBody?.isDynamic = false
        powerUpNode.physicsBody?.categoryBitMask = GlyphRunnerConstants.powerUpCategory
        powerUpNode.physicsBody?.contactTestBitMask = GlyphRunnerConstants.playerCategory
        powerUpNode.physicsBody?.collisionBitMask = 0

        // Pulsing animation
        let scaleUp = SKAction.scale(to: GlyphRunnerConstants.powerGlyphPulseScale, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        powerUpNode.run(SKAction.repeatForever(pulse))

        return powerUpNode
    }

    private func setupEnemies() {
        enemies.removeAll()
        enemiesReleased = 0
        enemyReleaseTimer = GlyphRunnerConstants.firstEnemyDelay

        let personalities: [EnemyPersonality] = [.chaser, .ambusher, .patrol, .random]
        let enemyColors: [SKColor] = [
            enemyColor,
            enemyColor.withAlphaComponent(0.9),
            SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0), // Orange
            SKColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)  // Green
        ]

        for i in 0..<GlyphRunnerConstants.enemyCount {
            let personality = personalities[i % personalities.count]
            let color = enemyColors[i % enemyColors.count]
            let enemy = GlyphRunnerEnemy(
                id: i,
                personality: personality,
                color: color,
                frightenedColor: frightenedColor,
                maze: maze
            )
            enemy.targetPlayer = player
            enemies.append(enemy)
            addChild(enemy)
        }
    }

    // MARK: - Swipe Gestures

    private func setupSwipeGestures() {
        guard let view = view else { return }

        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
            swipeRecognizers.append(swipe)
        }
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard isGameActive else { return }

        let direction: MoveDirection
        switch gesture.direction {
        case .up: direction = .up
        case .down: direction = .down
        case .left: direction = .left
        case .right: direction = .right
        default: return
        }

        player.setDirection(direction)
    }

    // MARK: - Update Loops

    private func updateEnemies(deltaTime: TimeInterval) {
        // Release enemies over time
        enemyReleaseTimer -= deltaTime
        if enemyReleaseTimer <= 0 && enemiesReleased < enemies.count {
            if let enemy = enemies.first(where: { $0.state == .inHome }) {
                enemy.release()
                enemiesReleased += 1
            }
            enemyReleaseTimer = GlyphRunnerConstants.enemyReleaseInterval
        }

        // Update all enemies
        for enemy in enemies {
            enemy.update(deltaTime: deltaTime, isScatterMode: isScatterMode)
        }
    }

    private func updatePowerUpState(deltaTime: TimeInterval) {
        guard isPowerUpActive else { return }

        powerUpTimer -= deltaTime

        // Flash enemies when power-up is about to expire
        if powerUpTimer <= GlyphRunnerConstants.powerUpWarningTime {
            for enemy in enemies where enemy.state == .frightened {
                enemy.flashWarning()
            }
        }

        if powerUpTimer <= 0 {
            endPowerUp()
        }
    }

    private func updateScatterChaseMode(deltaTime: TimeInterval) {
        scatterChaseTimer -= deltaTime

        if scatterChaseTimer <= 0 {
            isScatterMode.toggle()
            scatterChaseTimer = isScatterMode ?
                GlyphRunnerConstants.scatterDuration :
                GlyphRunnerConstants.chaseDuration

            for enemy in enemies where enemy.state != .frightened && enemy.state != .eaten {
                enemy.reverseDirection()
            }
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard isGameActive else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == GlyphRunnerConstants.playerCategory | GlyphRunnerConstants.glyphCategory {
            handleGlyphContact(contact)
        } else if collision == GlyphRunnerConstants.playerCategory | GlyphRunnerConstants.powerUpCategory {
            handlePowerUpContact(contact)
        } else if collision == GlyphRunnerConstants.playerCategory | GlyphRunnerConstants.enemyCategory {
            handleEnemyContact(contact)
        }
    }

    private func handleGlyphContact(_ contact: SKPhysicsContact) {
        let glyphBody = contact.bodyA.categoryBitMask == GlyphRunnerConstants.glyphCategory ?
            contact.bodyA : contact.bodyB

        guard let glyphNode = glyphBody.node as? SKShapeNode else { return }

        // Find and remove from tracking
        if let position = glyphNodes.first(where: { $0.value === glyphNode })?.key {
            glyphNodes.removeValue(forKey: position)
        }

        // Remove node with effect
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let group = SKAction.group([fadeOut, scaleUp])
        glyphNode.run(SKAction.sequence([group, SKAction.removeFromParent()]))

        // Update score
        score += GlyphRunnerConstants.glyphPoints
        glyphsRemaining -= 1
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .collect)
        gameDelegate?.gameScene(self, requestHaptic: .light)

        // Check level complete
        if glyphsRemaining == 0 && powerUpNodes.isEmpty {
            levelComplete()
        }
    }

    private func handlePowerUpContact(_ contact: SKPhysicsContact) {
        let powerUpBody = contact.bodyA.categoryBitMask == GlyphRunnerConstants.powerUpCategory ?
            contact.bodyA : contact.bodyB

        guard let powerUpNode = powerUpBody.node as? SKShapeNode else { return }

        // Find and remove from tracking
        if let position = powerUpNodes.first(where: { $0.value === powerUpNode })?.key {
            powerUpNodes.removeValue(forKey: position)
        }

        // Remove node with effect
        powerUpNode.removeAllActions()
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let group = SKAction.group([fadeOut, scaleUp])
        powerUpNode.run(SKAction.sequence([group, SKAction.removeFromParent()]))

        // Update score
        score += GlyphRunnerConstants.powerGlyphPoints
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .powerUp)
        gameDelegate?.gameScene(self, requestHaptic: .medium)

        // Activate power-up
        activatePowerUp()

        // Check level complete
        if glyphsRemaining == 0 && powerUpNodes.isEmpty {
            levelComplete()
        }
    }

    private func handleEnemyContact(_ contact: SKPhysicsContact) {
        let enemyBody = contact.bodyA.categoryBitMask == GlyphRunnerConstants.enemyCategory ?
            contact.bodyA : contact.bodyB

        guard let enemy = enemyBody.node as? GlyphRunnerEnemy else { return }

        if enemy.state == .frightened {
            // Eat the enemy
            eatEnemy(enemy)
        } else if enemy.state != .eaten {
            // Player dies
            playerDied()
        }
    }

    // MARK: - Power-Up

    private func activatePowerUp() {
        isPowerUpActive = true
        powerUpTimer = GlyphRunnerConstants.powerUpDuration
        consecutiveEnemiesEaten = 0

        for enemy in enemies where enemy.state != .eaten && enemy.state != .inHome {
            enemy.frighten()
        }
    }

    private func endPowerUp() {
        isPowerUpActive = false
        consecutiveEnemiesEaten = 0

        for enemy in enemies where enemy.state == .frightened {
            enemy.endFrighten()
        }
    }

    private func eatEnemy(_ enemy: GlyphRunnerEnemy) {
        enemy.eaten()

        // Calculate points (doubles each consecutive eat)
        let points = GlyphRunnerConstants.enemyBasePoints * Int(pow(2.0, Double(consecutiveEnemiesEaten)))
        consecutiveEnemiesEaten += 1

        score += points
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .hit)
        gameDelegate?.gameScene(self, requestHaptic: .heavy)

        // Show points at enemy location
        showPointsLabel(points: points, at: enemy.position)
    }

    private func showPointsLabel(points: Int, at position: CGPoint) {
        let label = SKLabelNode(text: "\(points)")
        label.fontName = "Menlo-Bold"
        label.fontSize = 16
        label.fontColor = .white
        label.position = position
        label.zPosition = 100
        addChild(label)

        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([moveUp, fadeOut])
        label.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }

    // MARK: - Player Death

    private func playerDied() {
        isGameActive = false
        lives -= 1

        gameDelegate?.gameScene(self, requestSound: .hit)
        gameDelegate?.gameScene(self, requestHaptic: .heavy)

        // Flash player
        let flash = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.fadeIn(withDuration: 0.1)
        ])
        player.run(SKAction.repeat(flash, count: 5)) { [weak self] in
            self?.handleDeath()
        }
    }

    private func handleDeath() {
        if lives > 0 {
            // Respawn
            respawn()
        } else {
            // Game over
            gameOver()
        }
    }

    private func respawn() {
        // Reset positions
        player.resetToStart()
        for enemy in enemies {
            enemy.reset()
        }

        // Reset state
        isPowerUpActive = false
        consecutiveEnemiesEaten = 0
        enemiesReleased = 0
        enemyReleaseTimer = GlyphRunnerConstants.firstEnemyDelay
        isScatterMode = true
        scatterChaseTimer = GlyphRunnerConstants.scatterDuration

        // Brief pause before resuming
        run(SKAction.wait(forDuration: GlyphRunnerConstants.respawnDelay)) { [weak self] in
            self?.isGameActive = true
        }
    }

    // MARK: - Level Complete

    private func levelComplete() {
        isGameActive = false

        // Level bonus
        let bonus = GlyphRunnerConstants.levelBonusBase * level
        score += bonus
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .waveComplete)
        gameDelegate?.gameScene(self, requestHaptic: .heavy)

        // Flash maze
        let flashNode = SKShapeNode(rectOf: size)
        flashNode.fillColor = playerColor.withAlphaComponent(0.3)
        flashNode.strokeColor = .clear
        flashNode.position = CGPoint(x: size.width/2, y: size.height/2)
        flashNode.zPosition = 50
        addChild(flashNode)

        let flash = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.fadeIn(withDuration: 0.2)
        ])
        flashNode.run(SKAction.sequence([
            SKAction.repeat(flash, count: 3),
            SKAction.removeFromParent()
        ])) { [weak self] in
            self?.startNextLevel()
        }
    }

    private func startNextLevel() {
        level += 1

        // Reset maze (glyphs and power-ups)
        for (_, node) in glyphNodes {
            node.removeFromParent()
        }
        for (_, node) in powerUpNodes {
            node.removeFromParent()
        }

        setupGlyphs()
        setupPowerUps()

        // Reset player and enemies
        player.resetToStart()
        for enemy in enemies {
            enemy.reset()
            enemy.increaseSpeed(forLevel: level)
        }

        // Reset state
        isPowerUpActive = false
        consecutiveEnemiesEaten = 0
        enemiesReleased = 0
        enemyReleaseTimer = GlyphRunnerConstants.firstEnemyDelay
        isScatterMode = true
        scatterChaseTimer = GlyphRunnerConstants.scatterDuration

        run(SKAction.wait(forDuration: GlyphRunnerConstants.levelTransitionDelay)) { [weak self] in
            self?.isGameActive = true
            self?.gameDelegate?.gameScene(self!, requestSound: .gameStart)
        }
    }

    // MARK: - Game Over

    private func gameOver() {
        isGameActive = false

        // Screen flash
        let flashNode = SKShapeNode(rectOf: size)
        flashNode.fillColor = enemyColor.withAlphaComponent(0.5)
        flashNode.strokeColor = .clear
        flashNode.position = CGPoint(x: size.width/2, y: size.height/2)
        flashNode.zPosition = 50
        addChild(flashNode)

        let flash = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.fadeIn(withDuration: 0.15)
        ])
        flashNode.run(SKAction.sequence([
            SKAction.repeat(flash, count: 3),
            SKAction.removeFromParent()
        ])) { [weak self] in
            guard let self = self else { return }
            self.gameDelegate?.gameSceneDidEnd(self, finalScore: self.score)
        }
    }

    // MARK: - Restart

    func restartGame() {
        // Remove all children
        removeAllChildren()
        removeAllActions()

        // Reset state
        score = 0
        level = 1
        lives = GlyphRunnerConstants.startingLives
        isGameActive = true
        isPowerUpActive = false
        consecutiveEnemiesEaten = 0
        lastUpdateTime = 0
        enemiesReleased = 0
        enemyReleaseTimer = GlyphRunnerConstants.firstEnemyDelay
        isScatterMode = true
        scatterChaseTimer = GlyphRunnerConstants.scatterDuration

        // Rebuild scene
        setupMaze()
        setupPlayer()
        setupGlyphs()
        setupPowerUps()
        setupEnemies()

        gameDelegate?.gameScene(self, didUpdateScore: 0)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }
}

// MARK: - Color Conversion Helper

import SwiftUI

private func skColor(from color: Color) -> SKColor {
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return SKColor(red: red, green: green, blue: blue, alpha: alpha)
}
