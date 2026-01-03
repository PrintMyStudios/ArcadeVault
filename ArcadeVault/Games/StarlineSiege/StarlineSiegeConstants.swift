import Foundation
import CoreGraphics

/// Tuning constants for Starline Siege game
enum StarlineSiegeConstants {
    // MARK: - Physics Categories (Bitmask)
    static let playerCategory: UInt32       = 0b00001  // 1
    static let enemyCategory: UInt32        = 0b00010  // 2
    static let playerBulletCategory: UInt32 = 0b00100  // 4
    static let enemyBulletCategory: UInt32  = 0b01000  // 8
    static let powerUpCategory: UInt32      = 0b10000  // 16

    // MARK: - Player Configuration
    static let playerWidthRatio: CGFloat = 0.12       // Width relative to screen width
    static let playerHeightRatio: CGFloat = 0.05      // Height relative to screen height
    static let playerBottomMargin: CGFloat = 60       // Distance from bottom of screen
    static let playerMoveSmoothing: CGFloat = 0.15    // Interpolation factor (0-1)

    // MARK: - Bullet Configuration
    static let playerBulletSpeed: CGFloat = 800       // Points per second (upward)
    static let enemyBulletSpeed: CGFloat = 300        // Points per second (downward)
    static let bulletWidth: CGFloat = 4
    static let bulletHeight: CGFloat = 12
    static let shootCooldown: TimeInterval = 0.25     // Seconds between player shots
    static let rapidFireCooldown: TimeInterval = 0.10 // Faster shooting with power-up
    static let multiShotSpread: CGFloat = 15          // Degrees spread for multi-shot

    // MARK: - Enemy Formation
    static let enemyColumns: Int = 7
    static let enemyRows: Int = 4
    static let enemyWidthRatio: CGFloat = 0.08        // Width relative to screen width
    static let enemyHeightRatio: CGFloat = 0.04       // Height relative to screen height
    static let enemyHorizontalSpacing: CGFloat = 1.4  // Multiplier of enemy width
    static let enemyVerticalSpacing: CGFloat = 1.6    // Multiplier of enemy height
    static let formationTopMargin: CGFloat = 100      // Top margin for HUD clearance

    // MARK: - Formation Movement
    static let formationMoveSpeed: CGFloat = 40       // Base horizontal speed (points/sec)
    static let formationDropDistance: CGFloat = 20    // Pixels to drop when hitting edge
    static let formationEdgeMargin: CGFloat = 20      // Margin before reversing direction
    static let formationSpeedIncreaseOnDrop: CGFloat = 1.03 // Speed multiplier after each drop
    static let waveSpeedMultiplier: CGFloat = 1.12    // Speed increase per wave
    static let maxFormationSpeed: CGFloat = 200       // Maximum speed cap

    // MARK: - Enemy Shooting
    static let enemyShootChance: CGFloat = 0.008      // Per-bottom-enemy per-frame chance
    static let maxEnemyBullets: Int = 3               // Max concurrent enemy bullets on screen
    static let enemyShootCooldown: TimeInterval = 1.0 // Min time between any enemy shot

    // MARK: - Wave Configuration
    static let waveTransitionDelay: TimeInterval = 2.0 // Pause between waves

    // MARK: - Scoring
    static let basicEnemyPoints: Int = 10
    static let fastEnemyPoints: Int = 15
    static let heavyEnemyPoints: Int = 25
    static let waveBonus: Int = 500                   // Bonus for clearing a wave

    // MARK: - Lives & Invincibility
    static let startingLives: Int = 3
    static let maxLives: Int = 5
    static let invincibilityDuration: TimeInterval = 2.0  // After player hit

    // MARK: - Power-Ups
    static let powerUpDropChance: CGFloat = 0.10      // 10% chance per enemy destroyed
    static let powerUpFallSpeed: CGFloat = 100        // Points per second
    static let powerUpSize: CGFloat = 28              // Diameter
    static let shieldDuration: TimeInterval = 8.0
    static let rapidFireDuration: TimeInterval = 6.0
    static let multiShotDuration: TimeInterval = 6.0

    // MARK: - Visual Effects
    static let playerGlowWidth: CGFloat = 4
    static let enemyGlowWidth: CGFloat = 2
    static let bulletGlowWidth: CGFloat = 3
    static let explosionDuration: TimeInterval = 0.35
    static let explosionParticleCount: Int = 8

    // MARK: - Touch Detection
    static let tapMaxDuration: TimeInterval = 0.15    // Max touch duration to count as tap
    static let tapMaxDistance: CGFloat = 10           // Max movement to count as tap

    // MARK: - Layout
    static let hudTopMargin: CGFloat = 60
    static let safeBottomMargin: CGFloat = 40
}
