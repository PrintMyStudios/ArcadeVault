import Foundation
import CoreGraphics

/// All tuning values and physics categories for Rivet Climb
enum RivetClimbConstants {

    // MARK: - Grid System

    /// Number of columns in the level grid
    static let columns: Int = 9

    /// Number of rows in the level grid
    static let rows: Int = 13

    // MARK: - Layout Margins

    /// Top margin for HUD clearance
    static let topMargin: CGFloat = 80

    /// Bottom margin
    static let bottomMargin: CGFloat = 40

    /// Side margins
    static let sideMargin: CGFloat = 10

    // MARK: - Player Movement Timing

    /// Time to complete one horizontal walk step (seconds)
    static let walkStepDuration: TimeInterval = 0.12

    /// Time to complete one vertical climb step (seconds)
    static let climbStepDuration: TimeInterval = 0.18

    /// Time for one falling step (seconds)
    static let fallStepDuration: TimeInterval = 0.08

    // MARK: - Player Visuals

    /// Player size as ratio of cell size
    static let playerSizeRatio: CGFloat = 0.65

    /// Player glow width
    static let playerGlowWidth: CGFloat = 3

    // MARK: - Obstacle Timing

    /// Time between obstacle step movements (seconds)
    static let obstacleStepInterval: TimeInterval = 0.3

    /// Base spawn interval at level 1 (seconds)
    static let baseSpawnInterval: TimeInterval = 2.5

    /// Spawn interval decrease per level (seconds)
    static let spawnIntervalDecreasePerLevel: TimeInterval = 0.2

    /// Minimum spawn interval (seconds)
    static let minSpawnInterval: TimeInterval = 1.0

    /// Maximum number of active obstacles
    static let maxObstacles: Int = 10

    /// Safety buffer: don't spawn if player within this many cells
    static let spawnSafetyBuffer: Int = 1

    // MARK: - Obstacle Visuals

    /// Obstacle size as ratio of cell size
    static let obstacleSizeRatio: CGFloat = 0.5

    /// Obstacle glow width
    static let obstacleGlowWidth: CGFloat = 2

    // MARK: - Obstacle Type Distribution

    /// Base percentage of rolling obstacles (vs falling)
    static let baseRollerPercent: Int = 80

    /// Roller percent at levels 3-4
    static let midRollerPercent: Int = 70

    /// Roller percent at level 5+
    static let lateRollerPercent: Int = 60

    // MARK: - Drop-Through Chances (by difficulty)

    /// Drop-through % for levels 1-2
    static let earlyDropThroughPercent: Int = 0

    /// Drop-through % for levels 3-4
    static let midDropThroughPercent: Int = 15

    /// Drop-through % for level 5+
    static let lateDropThroughPercent: Int = 30

    // MARK: - Collectibles

    /// Collectible size as ratio of cell size
    static let collectibleSizeRatio: CGFloat = 0.35

    /// Collectible glow width
    static let collectibleGlowWidth: CGFloat = 4

    // MARK: - Scoring

    /// Points per rivet collected
    static let rivetPoints: Int = 100

    /// Bonus for collecting all rivets
    static let allRivetsBonus: Int = 500

    /// Base points for level completion (multiplied by runLevel)
    static let levelCompleteBasePoints: Int = 1000

    /// Points per second remaining on timer
    static let timeBonus: Int = 10

    /// Streak bonus per consecutive rivet without damage
    static let streakBonus: Int = 50

    /// Danger bonus when obstacle passes within 1 cell
    static let dangerBonus: Int = 25

    // MARK: - Level Timing

    /// Time limit per level (seconds)
    static let levelTimeLimit: TimeInterval = 60

    // MARK: - Lives & Respawn

    /// Starting number of lives
    static let startingLives: Int = 3

    /// Maximum lives
    static let maxLives: Int = 5

    /// Invincibility duration after respawn (seconds)
    static let invincibilityDuration: TimeInterval = 2.0

    /// Cells to clear obstacles around player on respawn
    static let respawnClearRadius: Int = 2

    // MARK: - Input

    /// Hold duration before repeat triggers (seconds)
    static let holdRepeatDelay: TimeInterval = 0.2

    /// Repeat interval when holding (seconds)
    static let holdRepeatInterval: TimeInterval = 0.15

    /// Minimum swipe distance to register
    static let swipeThreshold: CGFloat = 30

    // MARK: - Physics Categories (Minimal - only for collectibles/goal)

    /// Player physics category
    static let playerCategory: UInt32 = 0b001

    /// Collectible physics category
    static let collectibleCategory: UInt32 = 0b010

    /// Goal physics category
    static let goalCategory: UInt32 = 0b100

    // MARK: - Visual Effects

    /// Platform visual thickness
    static let platformThickness: CGFloat = 8

    /// Ladder visual width ratio of cell
    static let ladderWidthRatio: CGFloat = 0.3

    /// Platform glow width
    static let platformGlowWidth: CGFloat = 1

    // MARK: - Hatch Alarm (Optional Polish)

    /// Run level at which hatch alarm activates
    static let hatchAlarmStartLevel: Int = 4

    /// Interval between hatch alarms (seconds)
    static let hatchAlarmInterval: TimeInterval = 15

    /// Duration of hatch alarm effect (seconds)
    static let hatchAlarmDuration: TimeInterval = 3

    /// Warning time before alarm activates (seconds)
    static let hatchAlarmWarning: TimeInterval = 1

    // MARK: - Helper Methods

    /// Calculate tile size for a given scene size
    static func tileSize(for sceneSize: CGSize) -> CGSize {
        let playableWidth = sceneSize.width - (sideMargin * 2)
        let playableHeight = sceneSize.height - topMargin - bottomMargin
        return CGSize(
            width: playableWidth / CGFloat(columns),
            height: playableHeight / CGFloat(rows)
        )
    }

    /// Calculate spawn interval for a given run level
    static func spawnInterval(for runLevel: Int) -> TimeInterval {
        let interval = baseSpawnInterval - (Double(runLevel - 1) * spawnIntervalDecreasePerLevel)
        return max(interval, minSpawnInterval)
    }

    /// Get roller percentage for a given run level
    static func rollerPercent(for runLevel: Int) -> Int {
        switch runLevel {
        case 1...2: return baseRollerPercent
        case 3...4: return midRollerPercent
        default: return lateRollerPercent
        }
    }

    /// Get drop-through percentage for a given run level
    static func dropThroughPercent(for runLevel: Int) -> Int {
        switch runLevel {
        case 1...2: return earlyDropThroughPercent
        case 3...4: return midDropThroughPercent
        default: return lateDropThroughPercent
        }
    }

    /// Get number of active spawn points for a given run level
    static func activeSpawnPoints(for runLevel: Int) -> Int {
        switch runLevel {
        case 1...2: return 2
        case 3...4: return 3
        default: return 99 // All spawn points
        }
    }
}
