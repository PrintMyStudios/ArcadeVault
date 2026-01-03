import SpriteKit
import SwiftUI

/// Game phases for state management
private enum GamePhase {
    case playing
    case waveClear
    case gameOver
}

/// Main gameplay scene for Starline Siege
class StarlineSiegeScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Delegate

    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Game Objects

    private var player: StarlineSiegePlayer!
    private var enemies: [StarlineSiegeEnemy] = []
    private var playerBullets: [StarlineSiegeBullet] = []
    private var enemyBullets: [StarlineSiegeBullet] = []
    private var activePowerUp: SKShapeNode?
    private var formationNode: SKNode!

    // MARK: - Game State

    private var score: Int = 0
    private var wave: Int = 1
    private var lives: Int = StarlineSiegeConstants.startingLives
    private var gamePhase: GamePhase = .playing

    // MARK: - Formation Movement

    private var formationDirection: CGFloat = 1  // 1 = right, -1 = left
    private var formationSpeed: CGFloat = StarlineSiegeConstants.formationMoveSpeed

    // MARK: - Timing

    private var lastUpdateTime: TimeInterval = 0
    private var currentTime: TimeInterval = 0
    private var lastEnemyShotTime: TimeInterval = 0

    // MARK: - Power-Up Timers

    private var shieldEndTime: TimeInterval = 0
    private var rapidFireEndTime: TimeInterval = 0
    private var multiShotEndTime: TimeInterval = 0

    // MARK: - Touch Detection (tap vs drag)

    private var touchStartTime: TimeInterval = 0
    private var touchStartLocation: CGPoint = .zero
    private var isDragging: Bool = false

    // MARK: - Theme Colors (cached)

    private var bgColor: SKColor = .black
    private var playerColor: SKColor = .cyan
    private var enemyColor: SKColor = .red
    private var bulletColor: SKColor = .white
    private var powerUpColor: SKColor = .green
    private var accentColor: SKColor = .magenta

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        cacheThemeColors()
        setupPhysics()
        setupPlayer()
        spawnWave()

        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }

    override func update(_ currentTime: TimeInterval) {
        guard gamePhase == .playing else { return }

        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        self.currentTime = currentTime

        player.updatePosition()
        updateFormation(deltaTime: deltaTime)
        updateBullets()
        updateEnemyShooting()
        updatePowerUpTimers()
        checkWaveComplete()
        checkGameOver()
    }

    // MARK: - Setup

    private func cacheThemeColors() {
        let palette = ThemeManager.shared.currentTheme.palette

        bgColor = skColor(from: palette.background)
        playerColor = skColor(from: palette.accent)
        enemyColor = skColor(from: palette.danger)
        bulletColor = skColor(from: palette.foreground)
        powerUpColor = skColor(from: palette.success)
        accentColor = skColor(from: palette.accentSecondary)

        backgroundColor = bgColor
    }

    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }

    private func setupPlayer() {
        player = StarlineSiegePlayer(color: playerColor, screenSize: size)
        addChild(player)
    }

    // MARK: - Wave Spawning

    private func spawnWave() {
        enemies.removeAll()

        // Create formation container node
        formationNode = SKNode()
        formationNode.position = CGPoint(
            x: size.width / 2,
            y: size.height - StarlineSiegeConstants.formationTopMargin
        )
        addChild(formationNode)

        let cols = StarlineSiegeConstants.enemyColumns
        let rows = StarlineSiegeConstants.enemyRows
        let enemyW = size.width * StarlineSiegeConstants.enemyWidthRatio
        let enemyH = size.height * StarlineSiegeConstants.enemyHeightRatio
        let spacingX = enemyW * StarlineSiegeConstants.enemyHorizontalSpacing
        let spacingY = enemyH * StarlineSiegeConstants.enemyVerticalSpacing

        let totalWidth = CGFloat(cols - 1) * spacingX
        let startX = -totalWidth / 2

        for row in 0..<rows {
            // Determine enemy type by row
            let enemyType: EnemyType
            switch row {
            case 0: enemyType = .heavy    // Top row: heavy enemies
            case 1: enemyType = .fast     // Second row: fast enemies
            default: enemyType = .basic   // Lower rows: basic enemies
            }

            // Vary color slightly by row for visual interest
            let rowColor = enemyColor.withAlphaComponent(1.0 - CGFloat(row) * 0.12)

            for col in 0..<cols {
                let enemy = StarlineSiegeEnemy(
                    type: enemyType,
                    row: row,
                    column: col,
                    color: rowColor,
                    damageColor: accentColor,
                    screenSize: size
                )

                let x = startX + CGFloat(col) * spacingX
                let y = -CGFloat(row) * spacingY
                enemy.position = CGPoint(x: x, y: y)
                enemy.startIdleAnimation()

                formationNode.addChild(enemy)
                enemies.append(enemy)
            }
        }

        // Set formation speed for this wave
        formationSpeed = StarlineSiegeConstants.formationMoveSpeed *
                         pow(StarlineSiegeConstants.waveSpeedMultiplier, CGFloat(wave - 1))
        formationSpeed = min(formationSpeed, StarlineSiegeConstants.maxFormationSpeed)
        formationDirection = 1
    }

    // MARK: - Formation Movement

    private func updateFormation(deltaTime: TimeInterval) {
        guard !enemies.isEmpty else { return }

        // Move formation horizontally
        let moveAmount = formationSpeed * CGFloat(deltaTime) * formationDirection
        formationNode.position.x += moveAmount

        // Check if formation hits screen edges
        let leftEdge = formationLeftEdge()
        let rightEdge = formationRightEdge()

        var shouldDrop = false

        if rightEdge >= size.width - StarlineSiegeConstants.formationEdgeMargin && formationDirection > 0 {
            formationDirection = -1
            shouldDrop = true
        } else if leftEdge <= StarlineSiegeConstants.formationEdgeMargin && formationDirection < 0 {
            formationDirection = 1
            shouldDrop = true
        }

        // Drop formation and increase speed
        if shouldDrop {
            formationNode.position.y -= StarlineSiegeConstants.formationDropDistance
            formationSpeed *= StarlineSiegeConstants.formationSpeedIncreaseOnDrop
        }
    }

    private func formationLeftEdge() -> CGFloat {
        var minX: CGFloat = .greatestFiniteMagnitude
        for enemy in enemies {
            let worldPos = formationNode.convert(enemy.position, to: self)
            minX = min(minX, worldPos.x)
        }
        return minX
    }

    private func formationRightEdge() -> CGFloat {
        var maxX: CGFloat = -.greatestFiniteMagnitude
        for enemy in enemies {
            let worldPos = formationNode.convert(enemy.position, to: self)
            maxX = max(maxX, worldPos.x)
        }
        return maxX
    }

    private func formationBottomEdge() -> CGFloat {
        var minY: CGFloat = .greatestFiniteMagnitude
        for enemy in enemies {
            let worldPos = formationNode.convert(enemy.position, to: self)
            minY = min(minY, worldPos.y)
        }
        return minY
    }

    // MARK: - Player Shooting

    private func playerShoot() {
        guard gamePhase == .playing else { return }
        guard player.canShoot(currentTime: currentTime) else { return }

        player.recordShot(at: currentTime)

        let spawnPos = player.getBulletSpawnPosition()
        let shotCount = player.getShotCount()

        if shotCount == 1 {
            // Single shot
            spawnPlayerBullet(at: spawnPos, angle: 0)
        } else {
            // Multi-shot spread
            let spreadRad = StarlineSiegeConstants.multiShotSpread * .pi / 180
            spawnPlayerBullet(at: spawnPos, angle: -spreadRad)
            spawnPlayerBullet(at: spawnPos, angle: 0)
            spawnPlayerBullet(at: spawnPos, angle: spreadRad)
        }

        gameDelegate?.gameScene(self, requestSound: .collect)
        gameDelegate?.gameScene(self, requestHaptic: .light)
    }

    private func spawnPlayerBullet(at position: CGPoint, angle: CGFloat) {
        let bullet = StarlineSiegeBullet(owner: .player, color: bulletColor, angle: angle)
        bullet.position = position
        addChild(bullet)
        bullet.fire()
        playerBullets.append(bullet)
    }

    // MARK: - Enemy Shooting

    private func updateEnemyShooting() {
        guard gamePhase == .playing else { return }
        guard currentTime - lastEnemyShotTime >= StarlineSiegeConstants.enemyShootCooldown else { return }
        guard enemyBullets.count < StarlineSiegeConstants.maxEnemyBullets else { return }

        // Find bottom-most enemy in each column (by world y-position)
        var bottomShooters: [StarlineSiegeEnemy] = []
        var columnMinY: [Int: (CGFloat, StarlineSiegeEnemy)] = [:]

        for enemy in enemies {
            let worldPos = formationNode.convert(enemy.position, to: self)
            if let existing = columnMinY[enemy.column] {
                if worldPos.y < existing.0 {
                    columnMinY[enemy.column] = (worldPos.y, enemy)
                }
            } else {
                columnMinY[enemy.column] = (worldPos.y, enemy)
            }
        }

        bottomShooters = columnMinY.values.map { $0.1 }

        // Random chance for each bottom shooter to fire
        for enemy in bottomShooters {
            if CGFloat.random(in: 0...1) < StarlineSiegeConstants.enemyShootChance {
                let worldPos = formationNode.convert(enemy.position, to: self)
                spawnEnemyBullet(at: worldPos)
                lastEnemyShotTime = currentTime
                break // Only one shot per frame
            }
        }
    }

    private func spawnEnemyBullet(at position: CGPoint) {
        let bullet = StarlineSiegeBullet(owner: .enemy, color: enemyColor)
        bullet.position = position
        addChild(bullet)
        bullet.fire()
        enemyBullets.append(bullet)
    }

    // MARK: - Bullet Cleanup

    private func updateBullets() {
        // Remove off-screen player bullets
        playerBullets.removeAll { bullet in
            if bullet.isOffScreen(screenHeight: size.height) {
                bullet.removeFromParent()
                return true
            }
            return false
        }

        // Remove off-screen enemy bullets
        enemyBullets.removeAll { bullet in
            if bullet.isOffScreen(screenHeight: size.height) {
                bullet.removeFromParent()
                return true
            }
            return false
        }
    }

    // MARK: - Power-Ups

    private func maybeSpawnPowerUp(at position: CGPoint) {
        // Only one power-up on screen at a time
        guard activePowerUp == nil else { return }
        guard CGFloat.random(in: 0...1) < StarlineSiegeConstants.powerUpDropChance else { return }

        let powerUpType = PowerUpType.allCases.randomElement()!
        let powerUpSize = StarlineSiegeConstants.powerUpSize

        let powerUp = SKShapeNode(circleOfRadius: powerUpSize / 2)
        powerUp.fillColor = powerUpColor
        powerUp.strokeColor = powerUpColor.withAlphaComponent(0.8)
        powerUp.lineWidth = 2
        powerUp.glowWidth = 4
        powerUp.position = position
        powerUp.name = "powerUp_\(powerUpType)"
        powerUp.zPosition = 5

        // Add icon inside
        let iconLabel = SKLabelNode(text: iconFor(powerUpType))
        iconLabel.fontSize = powerUpSize * 0.4
        iconLabel.fontName = "Menlo-Bold"
        iconLabel.fontColor = bgColor
        iconLabel.verticalAlignmentMode = .center
        iconLabel.horizontalAlignmentMode = .center
        powerUp.addChild(iconLabel)

        // Physics
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUpSize / 2)
        powerUp.physicsBody?.isDynamic = true
        powerUp.physicsBody?.affectedByGravity = false
        powerUp.physicsBody?.categoryBitMask = StarlineSiegeConstants.powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = StarlineSiegeConstants.playerCategory
        powerUp.physicsBody?.collisionBitMask = 0
        powerUp.physicsBody?.velocity = CGVector(dx: 0, dy: -StarlineSiegeConstants.powerUpFallSpeed)

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        powerUp.run(SKAction.repeatForever(pulse), withKey: "pulse")

        addChild(powerUp)
        activePowerUp = powerUp
    }

    private func iconFor(_ type: PowerUpType) -> String {
        switch type {
        case .shield: return "S"
        case .rapidFire: return "R"
        case .multiShot: return "M"
        }
    }

    private func collectPowerUp(_ powerUp: SKShapeNode) {
        guard let name = powerUp.name, name.hasPrefix("powerUp_") else { return }

        let typeString = String(name.dropFirst("powerUp_".count))

        if typeString == "shield" {
            player.activateShield(color: powerUpColor)
            shieldEndTime = currentTime + StarlineSiegeConstants.shieldDuration
        } else if typeString == "rapidFire" {
            player.activateRapidFire()
            rapidFireEndTime = currentTime + StarlineSiegeConstants.rapidFireDuration
        } else if typeString == "multiShot" {
            player.activateMultiShot()
            multiShotEndTime = currentTime + StarlineSiegeConstants.multiShotDuration
        }

        // Remove power-up with effect
        powerUp.removeAllActions()
        let fadeScale = SKAction.group([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.scale(to: 1.5, duration: 0.2)
        ])
        powerUp.run(SKAction.sequence([fadeScale, SKAction.removeFromParent()]))
        activePowerUp = nil

        gameDelegate?.gameScene(self, requestSound: .powerUp)
        gameDelegate?.gameScene(self, requestHaptic: .medium)
    }

    private func updatePowerUpTimers() {
        // Check power-up expirations
        if player.hasShield && currentTime >= shieldEndTime {
            player.deactivateShield()
        }
        if player.hasRapidFire && currentTime >= rapidFireEndTime {
            player.deactivateRapidFire()
        }
        if player.hasMultiShot && currentTime >= multiShotEndTime {
            player.deactivateMultiShot()
        }

        // Remove power-up if it falls off screen
        if let powerUp = activePowerUp, powerUp.position.y < -30 {
            powerUp.removeFromParent()
            activePowerUp = nil
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard gamePhase == .playing else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Player bullet hits enemy
        if collision == StarlineSiegeConstants.playerBulletCategory | StarlineSiegeConstants.enemyCategory {
            handlePlayerBulletHitEnemy(contact)
        }
        // Enemy bullet hits player
        else if collision == StarlineSiegeConstants.enemyBulletCategory | StarlineSiegeConstants.playerCategory {
            handleEnemyBulletHitPlayer(contact)
        }
        // Player collects power-up
        else if collision == StarlineSiegeConstants.playerCategory | StarlineSiegeConstants.powerUpCategory {
            handlePlayerCollectPowerUp(contact)
        }
        // Enemy collides with player
        else if collision == StarlineSiegeConstants.playerCategory | StarlineSiegeConstants.enemyCategory {
            handleEnemyHitPlayer()
        }
    }

    private func handlePlayerBulletHitEnemy(_ contact: SKPhysicsContact) {
        let bulletBody = contact.bodyA.categoryBitMask == StarlineSiegeConstants.playerBulletCategory ?
            contact.bodyA : contact.bodyB
        let enemyBody = contact.bodyA.categoryBitMask == StarlineSiegeConstants.enemyCategory ?
            contact.bodyA : contact.bodyB

        guard let bullet = bulletBody.node as? StarlineSiegeBullet,
              let enemy = enemyBody.node as? StarlineSiegeEnemy else { return }

        // Remove bullet
        bullet.removeFromParent()
        playerBullets.removeAll { $0 === bullet }

        // Damage enemy
        let destroyed = enemy.takeDamage()

        if destroyed {
            // Award points
            score += enemy.enemyType.points
            gameDelegate?.gameScene(self, didUpdateScore: score)

            // Get world position for effects
            let worldPos = formationNode.convert(enemy.position, to: self)

            // Explosion effect
            createExplosion(at: worldPos)

            // Maybe drop power-up
            maybeSpawnPowerUp(at: worldPos)

            // Remove enemy
            enemy.removeFromParent()
            enemies.removeAll { $0 === enemy }

            gameDelegate?.gameScene(self, requestSound: .hit)
            gameDelegate?.gameScene(self, requestHaptic: .medium)
        } else {
            gameDelegate?.gameScene(self, requestHaptic: .light)
        }
    }

    private func handleEnemyBulletHitPlayer(_ contact: SKPhysicsContact) {
        let bulletBody = contact.bodyA.categoryBitMask == StarlineSiegeConstants.enemyBulletCategory ?
            contact.bodyA : contact.bodyB

        guard let bullet = bulletBody.node as? StarlineSiegeBullet else { return }

        // Remove bullet
        bullet.removeFromParent()
        enemyBullets.removeAll { $0 === bullet }

        // Check if player has shield
        if player.hasShield {
            player.deactivateShield()
            gameDelegate?.gameScene(self, requestSound: .hit)
            gameDelegate?.gameScene(self, requestHaptic: .medium)
            return
        }

        // Check if player is invincible
        if player.isInvincible {
            return
        }

        // Player takes damage
        playerHit()
    }

    private func handlePlayerCollectPowerUp(_ contact: SKPhysicsContact) {
        let powerUpBody = contact.bodyA.categoryBitMask == StarlineSiegeConstants.powerUpCategory ?
            contact.bodyA : contact.bodyB

        guard let powerUp = powerUpBody.node as? SKShapeNode else { return }
        collectPowerUp(powerUp)
    }

    private func handleEnemyHitPlayer() {
        if player.hasShield {
            player.deactivateShield()
            gameDelegate?.gameScene(self, requestHaptic: .heavy)
            return
        }

        if player.isInvincible {
            return
        }

        playerHit()
    }

    // MARK: - Player Hit

    private func playerHit() {
        lives -= 1

        gameDelegate?.gameScene(self, requestSound: .hit)
        gameDelegate?.gameScene(self, requestHaptic: .heavy)

        if lives > 0 {
            // Respawn with invincibility
            player.startInvincibility(duration: StarlineSiegeConstants.invincibilityDuration)

            // Clear enemy bullets to give player a chance
            for bullet in enemyBullets {
                bullet.removeFromParent()
            }
            enemyBullets.removeAll()
        }
        // Game over will be checked in checkGameOver()
    }

    // MARK: - Explosions

    private func createExplosion(at position: CGPoint) {
        let particleCount = StarlineSiegeConstants.explosionParticleCount

        for i in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = accentColor
            particle.strokeColor = .clear
            particle.glowWidth = 3
            particle.position = position
            particle.zPosition = 10
            addChild(particle)

            let angle = CGFloat(i) * (2 * .pi / CGFloat(particleCount))
            let distance: CGFloat = 35
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance

            let move = SKAction.moveBy(x: dx, y: dy, duration: StarlineSiegeConstants.explosionDuration)
            let fade = SKAction.fadeOut(withDuration: StarlineSiegeConstants.explosionDuration)
            let scale = SKAction.scale(to: 0.1, duration: StarlineSiegeConstants.explosionDuration)
            let group = SKAction.group([move, fade, scale])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
        }
    }

    // MARK: - Wave Completion

    private func checkWaveComplete() {
        guard enemies.isEmpty else { return }
        guard gamePhase == .playing else { return }

        gamePhase = .waveClear

        // Award wave bonus
        score += StarlineSiegeConstants.waveBonus
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestSound: .waveComplete)
        gameDelegate?.gameScene(self, requestHaptic: .success)

        // Next wave
        wave += 1

        // Clear remaining bullets and power-ups
        for bullet in playerBullets { bullet.removeFromParent() }
        playerBullets.removeAll()
        for bullet in enemyBullets { bullet.removeFromParent() }
        enemyBullets.removeAll()
        activePowerUp?.removeFromParent()
        activePowerUp = nil

        formationNode?.removeFromParent()
        formationNode = nil

        // Delay then spawn next wave
        run(SKAction.wait(forDuration: StarlineSiegeConstants.waveTransitionDelay)) { [weak self] in
            guard let self = self else { return }
            self.spawnWave()
            self.gamePhase = .playing
            self.gameDelegate?.gameScene(self, requestSound: .gameStart)
        }
    }

    // MARK: - Game Over

    private func checkGameOver() {
        guard gamePhase == .playing else { return }

        // Check if enemies reached player level
        let bottomY = formationBottomEdge()
        let dangerY = player.position.y + 40

        if bottomY <= dangerY || lives <= 0 {
            triggerGameOver()
        }
    }

    private func triggerGameOver() {
        gamePhase = .gameOver

        gameDelegate?.gameScene(self, requestSound: .gameOver)
        gameDelegate?.gameScene(self, requestHaptic: .error)

        // Screen flash effect
        let flash = SKShapeNode(rectOf: size)
        flash.fillColor = enemyColor.withAlphaComponent(0.4)
        flash.strokeColor = .clear
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 100
        addChild(flash)

        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.15)
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        flash.run(SKAction.sequence([
            SKAction.repeat(sequence, count: 3),
            SKAction.removeFromParent()
        ])) { [weak self] in
            guard let self = self else { return }
            self.gameDelegate?.gameSceneDidEnd(self, finalScore: self.score)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        touchStartTime = currentTime
        touchStartLocation = touch.location(in: self)
        isDragging = false

        // Start moving player toward touch
        player.setTargetX(touchStartLocation.x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)

        // Check if this counts as dragging
        let distance = hypot(location.x - touchStartLocation.x, location.y - touchStartLocation.y)
        if distance > StarlineSiegeConstants.tapMaxDistance {
            isDragging = true
        }

        // Update player target
        player.setTargetX(location.x)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if this was a tap (not a drag)
        let duration = currentTime - touchStartTime
        if !isDragging && duration < StarlineSiegeConstants.tapMaxDuration {
            playerShoot()
        }

        isDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }

    // MARK: - Restart

    func restartGame() {
        // Remove everything
        removeAllChildren()
        removeAllActions()

        // Clear all arrays
        enemies.removeAll()
        playerBullets.removeAll()
        enemyBullets.removeAll()
        activePowerUp = nil
        formationNode = nil

        // Reset state
        score = 0
        wave = 1
        lives = StarlineSiegeConstants.startingLives
        gamePhase = .playing

        formationDirection = 1
        formationSpeed = StarlineSiegeConstants.formationMoveSpeed

        // Reset timing
        lastUpdateTime = 0
        currentTime = 0
        lastEnemyShotTime = 0
        shieldEndTime = 0
        rapidFireEndTime = 0
        multiShotEndTime = 0

        // Reset touch state
        isDragging = false

        // Re-cache theme colors (handles mid-session theme switch)
        cacheThemeColors()

        // Rebuild scene
        setupPlayer()
        spawnWave()

        gameDelegate?.gameScene(self, didUpdateScore: 0)
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }

    // MARK: - Color Conversion Helper

    private func skColor(from color: Color) -> SKColor {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
