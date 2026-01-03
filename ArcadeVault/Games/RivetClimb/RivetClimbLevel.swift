import SpriteKit

// MARK: - Level Cell Types

/// Types of cells in the level grid
enum LevelCell: Character {
    case empty = "."           // Air - not walkable
    case platform = "="        // Solid platform - walkable
    case ladder = "H"          // Ladder only - climbable, not walkable
    case platformLadder = "+"  // Platform with ladder - walkable AND climbable
    case spawn = "S"           // Obstacle spawn point - treat as platform
    case playerStart = "P"     // Player start position - treat as platform
    case goal = "G"            // Goal/hatch - treat as platform
    case collectible = "*"     // Rivet collectible - on platform, walkable

    /// Whether this cell is walkable (player can stand on it)
    var isWalkable: Bool {
        switch self {
        case .platform, .platformLadder, .spawn, .playerStart, .goal, .collectible:
            return true
        case .empty, .ladder:
            return false
        }
    }

    /// Whether this cell has a ladder (player can climb)
    var hasLadder: Bool {
        switch self {
        case .ladder, .platformLadder:
            return true
        default:
            return false
        }
    }

    /// Whether obstacles can roll on this cell
    var isObstacleWalkable: Bool {
        isWalkable // Same as player walkability
    }
}

// MARK: - Level Position

/// A position in the level grid
struct LevelPosition: Hashable, Equatable {
    let col: Int
    let row: Int

    /// Create a position offset by the given amounts
    func offset(dc: Int = 0, dr: Int = 0) -> LevelPosition {
        LevelPosition(col: col + dc, row: row + dr)
    }

    /// Check if position is within grid bounds
    func isValid(columns: Int = RivetClimbConstants.columns, rows: Int = RivetClimbConstants.rows) -> Bool {
        col >= 0 && col < columns && row >= 0 && row < rows
    }

    /// Manhattan distance to another position
    func distance(to other: LevelPosition) -> Int {
        abs(col - other.col) + abs(row - other.row)
    }
}

// MARK: - Rivet Move Direction

/// Direction of movement for RivetClimb
enum RivetMoveDirection {
    case left
    case right
    case up
    case down
    case none

    /// Column offset for this direction
    var dc: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        default: return 0
        }
    }

    /// Row offset for this direction
    var dr: Int {
        switch self {
        case .up: return 1
        case .down: return -1
        default: return 0
        }
    }

    /// Whether this is a horizontal direction
    var isHorizontal: Bool {
        self == .left || self == .right
    }

    /// Whether this is a vertical direction
    var isVertical: Bool {
        self == .up || self == .down
    }
}

// MARK: - Level Data

/// Manages level layout, parsing, and coordinate conversion
class RivetClimbLevel {

    // MARK: - Properties

    /// The grid of cells (indexed by [col][row], row 0 = bottom)
    private var grid: [[LevelCell]]

    /// Number of columns
    let columns: Int

    /// Number of rows
    let rows: Int

    /// Calculated tile size for current scene
    private(set) var tileSize: CGSize = .zero

    /// Scene size for coordinate conversion
    private(set) var sceneSize: CGSize = .zero

    /// Player start position
    private(set) var playerStartPosition: LevelPosition = LevelPosition(col: 4, row: 0)

    /// Goal position
    private(set) var goalPosition: LevelPosition = LevelPosition(col: 4, row: 12)

    /// All spawn point positions
    private(set) var spawnPositions: [LevelPosition] = []

    /// All collectible positions
    private(set) var collectiblePositions: [LevelPosition] = []

    /// Current layout index (0, 1, or 2)
    private(set) var currentLayoutIndex: Int = 0

    // MARK: - Initialization

    init() {
        self.columns = RivetClimbConstants.columns
        self.rows = RivetClimbConstants.rows

        // Initialize empty grid
        self.grid = Array(repeating: Array(repeating: .empty, count: rows), count: columns)

        // Load first level
        loadLevel(index: 0)
    }

    // MARK: - Level Loading

    /// Load a level by index (0, 1, or 2)
    func loadLevel(index: Int) {
        currentLayoutIndex = index % Self.levelLayouts.count
        let layout = Self.levelLayouts[currentLayoutIndex]
        parseLayout(layout)
    }

    /// Parse an ASCII layout string into the grid
    private func parseLayout(_ layout: String) {
        // Reset special positions
        spawnPositions = []
        collectiblePositions = []

        let lines = layout.components(separatedBy: "\n").filter { !$0.isEmpty }

        for (lineIndex, line) in lines.enumerated() {
            // ASCII lines are top-to-bottom; row = (rows-1) - lineIndex
            let row = (rows - 1) - lineIndex

            for (colIndex, char) in line.enumerated() {
                guard colIndex < columns, row >= 0, row < rows else { continue }

                let cell = LevelCell(rawValue: char) ?? .empty
                grid[colIndex][row] = cell

                let pos = LevelPosition(col: colIndex, row: row)

                switch cell {
                case .playerStart:
                    playerStartPosition = pos
                case .goal:
                    goalPosition = pos
                case .spawn:
                    spawnPositions.append(pos)
                case .collectible:
                    collectiblePositions.append(pos)
                default:
                    break
                }
            }
        }
    }

    /// Configure tile size for a given scene size
    func configureForScene(size: CGSize) {
        sceneSize = size
        tileSize = RivetClimbConstants.tileSize(for: size)
    }

    // MARK: - Cell Access

    /// Get the cell at a position
    func cell(at position: LevelPosition) -> LevelCell {
        guard position.isValid(columns: columns, rows: rows) else {
            return .empty
        }
        return grid[position.col][position.row]
    }

    /// Get the cell at column and row
    func cell(col: Int, row: Int) -> LevelCell {
        cell(at: LevelPosition(col: col, row: row))
    }

    /// Check if position is a platform (walkable)
    func isPlatform(at position: LevelPosition) -> Bool {
        cell(at: position).isWalkable
    }

    /// Check if position is a platform
    func isPlatform(col: Int, row: Int) -> Bool {
        isPlatform(at: LevelPosition(col: col, row: row))
    }

    /// Check if position has a ladder
    func isLadder(at position: LevelPosition) -> Bool {
        cell(at: position).hasLadder
    }

    /// Check if position has a ladder
    func isLadder(col: Int, row: Int) -> Bool {
        isLadder(at: LevelPosition(col: col, row: row))
    }

    // MARK: - Movement Checks

    /// Check if player can walk from current position in given direction
    func canWalk(from position: LevelPosition, direction: RivetMoveDirection) -> Bool {
        guard direction.isHorizontal else { return false }

        let target = position.offset(dc: direction.dc)
        guard target.isValid(columns: columns, rows: rows) else { return false }

        return isPlatform(at: target)
    }

    /// Check if player can climb from current position in given direction
    func canClimb(from position: LevelPosition, direction: RivetMoveDirection) -> Bool {
        guard direction.isVertical else { return false }

        // For climbing up: current cell must have ladder, target cell must have ladder or be platform+ladder
        // For climbing down: target cell must have ladder

        if direction == .up {
            // Must be on a ladder to climb up
            guard isLadder(at: position) else { return false }

            let target = position.offset(dr: 1)
            guard target.isValid(columns: columns, rows: rows) else { return false }

            // Target must have ladder (H or +)
            return isLadder(at: target)
        } else {
            // Climbing down
            let target = position.offset(dr: -1)
            guard target.isValid(columns: columns, rows: rows) else { return false }

            // Target must have ladder
            return isLadder(at: target)
        }
    }

    /// Check if player can start climbing from a grounded position (at ladder bottom)
    func canStartClimbing(from position: LevelPosition) -> Bool {
        // Must be on a platform that has a ladder, or adjacent to ladder above
        let above = position.offset(dr: 1)
        return isLadder(at: above) || (isPlatform(at: position) && isLadder(at: position))
    }

    /// Check if player can dismount from ladder to a platform
    func canDismount(from position: LevelPosition, direction: RivetMoveDirection) -> Bool {
        guard direction.isHorizontal else { return false }

        let target = position.offset(dc: direction.dc)
        guard target.isValid(columns: columns, rows: rows) else { return false }

        return isPlatform(at: target)
    }

    // MARK: - Coordinate Conversion

    /// Convert grid position to world (scene) coordinates
    func worldPosition(for gridPos: LevelPosition) -> CGPoint {
        worldPosition(col: gridPos.col, row: gridPos.row)
    }

    /// Convert column and row to world coordinates
    func worldPosition(col: Int, row: Int) -> CGPoint {
        let x = RivetClimbConstants.sideMargin + (CGFloat(col) + 0.5) * tileSize.width
        let y = RivetClimbConstants.bottomMargin + (CGFloat(row) + 0.5) * tileSize.height
        return CGPoint(x: x, y: y)
    }

    /// Convert world coordinates to nearest grid position
    func gridPosition(for worldPos: CGPoint) -> LevelPosition {
        let col = Int((worldPos.x - RivetClimbConstants.sideMargin) / tileSize.width)
        let row = Int((worldPos.y - RivetClimbConstants.bottomMargin) / tileSize.height)
        return LevelPosition(
            col: max(0, min(columns - 1, col)),
            row: max(0, min(rows - 1, row))
        )
    }

    // MARK: - Visual Node Creation

    /// Create a visual node representing the level (platforms and ladders)
    func createLevelNode(platformColor: SKColor, ladderColor: SKColor, goalColor: SKColor) -> SKNode {
        let levelNode = SKNode()

        for col in 0..<columns {
            for row in 0..<rows {
                let cell = grid[col][row]
                let worldPos = worldPosition(col: col, row: row)

                // Draw platform if walkable
                if cell.isWalkable && cell != .goal {
                    let platformNode = createPlatformNode(color: platformColor)
                    platformNode.position = CGPoint(x: worldPos.x, y: worldPos.y - tileSize.height / 2 + RivetClimbConstants.platformThickness / 2)
                    levelNode.addChild(platformNode)
                }

                // Draw goal platform
                if cell == .goal {
                    let goalNode = createGoalNode(color: goalColor)
                    goalNode.position = worldPos
                    levelNode.addChild(goalNode)
                }

                // Draw ladder if has ladder
                if cell.hasLadder {
                    let ladderNode = createLadderNode(color: ladderColor)
                    ladderNode.position = worldPos
                    levelNode.addChild(ladderNode)
                }
            }
        }

        return levelNode
    }

    private func createPlatformNode(color: SKColor) -> SKShapeNode {
        let node = SKShapeNode(rectOf: CGSize(width: tileSize.width, height: RivetClimbConstants.platformThickness))
        node.fillColor = color
        node.strokeColor = color.withAlphaComponent(0.8)
        node.lineWidth = RivetClimbConstants.platformGlowWidth
        node.glowWidth = RivetClimbConstants.platformGlowWidth
        return node
    }

    private func createLadderNode(color: SKColor) -> SKShapeNode {
        let ladderWidth = tileSize.width * RivetClimbConstants.ladderWidthRatio
        let ladderHeight = tileSize.height

        // Create ladder shape (two vertical rails with horizontal rungs)
        let path = CGMutablePath()

        // Left rail
        path.move(to: CGPoint(x: -ladderWidth / 2, y: -ladderHeight / 2))
        path.addLine(to: CGPoint(x: -ladderWidth / 2, y: ladderHeight / 2))

        // Right rail
        path.move(to: CGPoint(x: ladderWidth / 2, y: -ladderHeight / 2))
        path.addLine(to: CGPoint(x: ladderWidth / 2, y: ladderHeight / 2))

        // Rungs (3 rungs)
        let rungCount = 3
        for i in 0..<rungCount {
            let y = -ladderHeight / 2 + ladderHeight * CGFloat(i + 1) / CGFloat(rungCount + 1)
            path.move(to: CGPoint(x: -ladderWidth / 2, y: y))
            path.addLine(to: CGPoint(x: ladderWidth / 2, y: y))
        }

        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.lineWidth = 2
        node.lineCap = .round
        return node
    }

    private func createGoalNode(color: SKColor) -> SKShapeNode {
        // Create a hatch/goal marker
        let size = tileSize.width * 0.6

        let path = CGMutablePath()
        // Octagon shape for hatch
        let corners = 8
        for i in 0..<corners {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(corners) - .pi / 8
            let x = cos(angle) * size / 2
            let y = sin(angle) * size / 2
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        // Inner cross
        let innerSize = size * 0.3
        path.move(to: CGPoint(x: -innerSize, y: 0))
        path.addLine(to: CGPoint(x: innerSize, y: 0))
        path.move(to: CGPoint(x: 0, y: -innerSize))
        path.addLine(to: CGPoint(x: 0, y: innerSize))

        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.fillColor = color.withAlphaComponent(0.3)
        node.lineWidth = 2
        node.glowWidth = 4
        return node
    }

    // MARK: - Level Layouts

    /// The 3 level layouts (ASCII, top-to-bottom in strings)
    /// Row 12 at top, Row 0 at bottom
    static let levelLayouts: [String] = [
        // Level 1: Tutorial - Simple layout
        """
        ....G....
        =========
        H.......H
        +.......+
        H...*...H
        =========
        .........
        +.......+
        H.......H
        =========
        .S.....S.
        =========
        ....P....
        """,

        // Level 2: Medium - More platforms, more paths
        """
        ....G....
        ===+=+===
        .H.H.H...
        .+.+.+=+.
        .H.H.*.H.
        ===+===+.
        S..*..*.H
        .=====+==
        .H...H.H.
        .+=====+.
        .H.....H.
        ===+S+===
        ....P....
        """,

        // Level 3: Hard - Maze-like, multiple routes
        """
        ....G....
        =+=+=+=+=
        .H.H.H.H.
        =+.+.+.+=
        .H.*.*.H.
        =+=====+=
        S.H...H.S
        .=+===+..
        .H.H.H.H.
        =+.+=+.+=
        .H...H...
        ===+S+===
        ....P....
        """
    ]

    // MARK: - Collectible Variants

    /// Get variant collectible positions for replayability
    static func collectibleVariant(for layoutIndex: Int, variant: Int) -> [LevelPosition] {
        // Define 2-3 variants per layout
        let variants: [[[LevelPosition]]] = [
            // Level 1 variants
            [
                [LevelPosition(col: 4, row: 8)], // Default
                [LevelPosition(col: 2, row: 8), LevelPosition(col: 6, row: 8)], // Two rivets
                [LevelPosition(col: 4, row: 4)] // Different position
            ],
            // Level 2 variants
            [
                [LevelPosition(col: 4, row: 8), LevelPosition(col: 2, row: 6), LevelPosition(col: 6, row: 6)],
                [LevelPosition(col: 1, row: 4), LevelPosition(col: 7, row: 4)],
                [LevelPosition(col: 4, row: 6)]
            ],
            // Level 3 variants
            [
                [LevelPosition(col: 3, row: 8), LevelPosition(col: 5, row: 8)],
                [LevelPosition(col: 1, row: 6), LevelPosition(col: 7, row: 6)],
                [LevelPosition(col: 4, row: 4), LevelPosition(col: 2, row: 8), LevelPosition(col: 6, row: 8)]
            ]
        ]

        let layoutVariants = variants[layoutIndex % variants.count]
        return layoutVariants[variant % layoutVariants.count]
    }
}
