import Foundation
import CoreGraphics

/// Tuning constants for Glyph Runner game
enum GlyphRunnerConstants {
    // MARK: - Grid System
    static let mazeColumns: Int = 15        // Odd number for symmetry
    static let mazeRows: Int = 21           // Tall for portrait mode
    static let wallThickness: CGFloat = 2   // Visual wall stroke width

    // MARK: - Movement Timing
    static let playerMoveSpeed: TimeInterval = 0.15   // Time to move one tile
    static let enemyBaseMoveSpeed: TimeInterval = 0.20 // Base enemy speed
    static let enemySpeedIncreasePerLevel: TimeInterval = 0.015 // Speed increase per level
    static let minEnemyMoveSpeed: TimeInterval = 0.10  // Fastest enemy speed

    // MARK: - Power-Up Timing
    static let powerUpDuration: TimeInterval = 8.0     // Seconds enemies are vulnerable
    static let powerUpWarningTime: TimeInterval = 2.0  // Flash enemies when expiring

    // MARK: - Enemy Release
    static let enemyReleaseInterval: TimeInterval = 3.0 // Time between enemy releases
    static let firstEnemyDelay: TimeInterval = 2.0      // Delay before first enemy exits

    // MARK: - State Machine Timing
    static let scatterDuration: TimeInterval = 7.0      // Scatter mode duration
    static let chaseDuration: TimeInterval = 20.0       // Chase mode duration

    // MARK: - Level Transitions
    static let levelTransitionDelay: TimeInterval = 2.0
    static let deathPauseDelay: TimeInterval = 1.5
    static let respawnDelay: TimeInterval = 1.0

    // MARK: - Scoring
    static let glyphPoints: Int = 10
    static let powerGlyphPoints: Int = 50
    static let enemyBasePoints: Int = 100   // Doubles each consecutive eat: 100, 200, 400, 800
    static let levelBonusBase: Int = 1000   // Bonus per level completed

    // MARK: - Lives
    static let startingLives: Int = 3
    static let maxLives: Int = 5
    static let extraLifeScore: Int = 10000  // Award extra life at this score

    // MARK: - Enemies
    static let enemyCount: Int = 4

    // MARK: - Physics Categories
    static let playerCategory: UInt32    = 0b00001  // 1
    static let wallCategory: UInt32      = 0b00010  // 2
    static let glyphCategory: UInt32     = 0b00100  // 4
    static let powerUpCategory: UInt32   = 0b01000  // 8
    static let enemyCategory: UInt32     = 0b10000  // 16

    // MARK: - Visual Sizing (relative to tile size)
    static let playerSizeRatio: CGFloat = 0.7       // Player size relative to tile
    static let enemySizeRatio: CGFloat = 0.7        // Enemy size relative to tile
    static let glyphSizeRatio: CGFloat = 0.2        // Small glyph relative to tile
    static let powerGlyphSizeRatio: CGFloat = 0.5   // Power glyph relative to tile

    // MARK: - Visual Effects
    static let playerGlowWidth: CGFloat = 4
    static let enemyGlowWidth: CGFloat = 3
    static let glyphGlowWidth: CGFloat = 2
    static let powerGlyphPulseScale: CGFloat = 1.3  // Max scale during pulse

    // MARK: - Safe Margins
    static let mazeTopMargin: CGFloat = 80          // Space for HUD
    static let mazeBottomMargin: CGFloat = 40       // Bottom padding
    static let mazeSideMargin: CGFloat = 10         // Side padding
}
