import SpriteKit

// MARK: - Grid Position

struct GridPosition: Hashable, Equatable {
    let col: Int
    let row: Int

    func offset(by direction: MoveDirection) -> GridPosition {
        let delta = direction.gridOffset
        return GridPosition(col: col + delta.col, row: row + delta.row)
    }

    func offset(by direction: MoveDirection, distance: Int) -> GridPosition {
        let delta = direction.gridOffset
        return GridPosition(col: col + delta.col * distance, row: row + delta.row * distance)
    }

    func isValid(cols: Int, rows: Int) -> Bool {
        col >= 0 && col < cols && row >= 0 && row < rows
    }

    func distance(to other: GridPosition) -> Int {
        abs(col - other.col) + abs(row - other.row)
    }
}

// MARK: - Move Direction

enum MoveDirection: CaseIterable {
    case up, down, left, right, none

    var gridOffset: (col: Int, row: Int) {
        switch self {
        case .up: return (0, 1)
        case .down: return (0, -1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        case .none: return (0, 0)
        }
    }

    var opposite: MoveDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        case .none: return .none
        }
    }

    var rotation: CGFloat {
        switch self {
        case .up: return .pi / 2
        case .down: return -.pi / 2
        case .left: return .pi
        case .right: return 0
        case .none: return 0
        }
    }

    static var moveable: [MoveDirection] {
        [.up, .down, .left, .right]
    }
}

// MARK: - Cell Type

enum CellType: Character {
    case wall = "#"
    case path = "."
    case enemyHome = "H"
    case enemyDoor = "D"
    case playerStart = "P"
    case powerUp = "O"
}

// MARK: - Glyph Runner Maze

class GlyphRunnerMaze {
    let columns: Int
    let rows: Int
    private(set) var grid: [[CellType]]
    private(set) var tileSize: CGFloat = 0
    private(set) var mazeOrigin: CGPoint = .zero

    // Computed positions
    private(set) var playerStartPosition: GridPosition = GridPosition(col: 7, row: 1)
    private(set) var enemyHomePositions: [GridPosition] = []
    private(set) var enemyDoorPosition: GridPosition = GridPosition(col: 7, row: 11)
    private(set) var powerUpPositions: [GridPosition] = []
    private(set) var glyphPositions: [GridPosition] = []

    init() {
        self.columns = GlyphRunnerConstants.mazeColumns
        self.rows = GlyphRunnerConstants.mazeRows
        self.grid = []
        loadMazeLayout()
        findSpecialPositions()
    }

    // MARK: - Maze Layout

    private func loadMazeLayout() {
        // Pre-designed maze layout (15 columns x 21 rows)
        // Uses bilateral symmetry for classic arcade feel
        // Legend: # = wall, . = path, H = enemy home, D = enemy door, P = player start, O = power-up
        let layout = """
        ###############
        #O....#.#....O#
        #.###.#.#.###.#
        #.#...#.#...#.#
        #.#.#.....#.#.#
        #...#.###.#...#
        ###.#.#.#.#.###
        #.....#.#.....#
        #.###.#.#.###.#
        #.#...#D#...#.#
        #.#.#HHHHH#.#.#
        #...#HHHHH#...#
        ###.#HHHHH#.###
        #.....#.#.....#
        #.###.#.#.###.#
        #.#...#.#...#.#
        #.#.#.....#.#.#
        #...#.###.#...#
        ###.#.#.#.#.###
        #O....#P#....O#
        ###############
        """

        let lines = layout.split(separator: "\n").reversed()
        grid = lines.map { line in
            line.map { char in
                CellType(rawValue: char) ?? .wall
            }
        }
    }

    private func findSpecialPositions() {
        enemyHomePositions = []
        powerUpPositions = []
        glyphPositions = []

        for row in 0..<rows {
            for col in 0..<columns {
                let cell = grid[row][col]
                let pos = GridPosition(col: col, row: row)

                switch cell {
                case .playerStart:
                    playerStartPosition = pos
                    glyphPositions.append(pos) // Player start is also a path with glyph
                case .enemyHome:
                    enemyHomePositions.append(pos)
                case .enemyDoor:
                    enemyDoorPosition = pos
                case .powerUp:
                    powerUpPositions.append(pos)
                case .path:
                    glyphPositions.append(pos)
                case .wall:
                    break
                }
            }
        }
    }

    // MARK: - Coordinate Conversion

    func calculateTileSize(for sceneSize: CGSize) {
        let availableWidth = sceneSize.width - (GlyphRunnerConstants.mazeSideMargin * 2)
        let availableHeight = sceneSize.height - GlyphRunnerConstants.mazeTopMargin - GlyphRunnerConstants.mazeBottomMargin

        let tileWidth = availableWidth / CGFloat(columns)
        let tileHeight = availableHeight / CGFloat(rows)

        // Use the smaller dimension to ensure maze fits
        tileSize = min(tileWidth, tileHeight)

        // Center the maze
        let mazeWidth = tileSize * CGFloat(columns)
        let mazeHeight = tileSize * CGFloat(rows)
        mazeOrigin = CGPoint(
            x: (sceneSize.width - mazeWidth) / 2,
            y: GlyphRunnerConstants.mazeBottomMargin + (availableHeight - mazeHeight) / 2
        )
    }

    func worldPosition(for gridPos: GridPosition) -> CGPoint {
        let x = CGFloat(gridPos.col) * tileSize + tileSize / 2 + mazeOrigin.x
        let y = CGFloat(gridPos.row) * tileSize + tileSize / 2 + mazeOrigin.y
        return CGPoint(x: x, y: y)
    }

    func gridPosition(for worldPos: CGPoint) -> GridPosition {
        let col = Int((worldPos.x - mazeOrigin.x) / tileSize)
        let row = Int((worldPos.y - mazeOrigin.y) / tileSize)
        return GridPosition(col: col.clamped(to: 0...(columns - 1)),
                           row: row.clamped(to: 0...(rows - 1)))
    }

    // MARK: - Walkability

    func isWalkable(at position: GridPosition) -> Bool {
        guard position.isValid(cols: columns, rows: rows) else { return false }
        let cell = grid[position.row][position.col]
        return cell != .wall
    }

    func canMove(from position: GridPosition, direction: MoveDirection) -> Bool {
        let newPos = position.offset(by: direction)
        return isWalkable(at: newPos)
    }

    func validDirections(from position: GridPosition, excluding: MoveDirection = .none) -> [MoveDirection] {
        MoveDirection.moveable.filter { direction in
            direction != excluding && canMove(from: position, direction: direction)
        }
    }

    func isIntersection(at position: GridPosition) -> Bool {
        validDirections(from: position).count > 2
    }

    func isEnemyHome(at position: GridPosition) -> Bool {
        let cell = grid[position.row][position.col]
        return cell == .enemyHome || cell == .enemyDoor
    }

    // MARK: - Visual Rendering

    func createMazeNode(wallColor: SKColor, backgroundColor: SKColor) -> SKNode {
        let mazeNode = SKNode()
        mazeNode.name = "maze"

        // Create walls
        for row in 0..<rows {
            for col in 0..<columns {
                if grid[row][col] == .wall {
                    let wallNode = createWallNode(col: col, row: row, color: wallColor)
                    mazeNode.addChild(wallNode)
                }
            }
        }

        // Create enemy home border
        let homeNode = createEnemyHomeBorder(color: wallColor)
        mazeNode.addChild(homeNode)

        return mazeNode
    }

    private func createWallNode(col: Int, row: Int, color: SKColor) -> SKShapeNode {
        let size = tileSize - 2 // Slight gap between walls
        let rect = CGRect(x: -size/2, y: -size/2, width: size, height: size)
        let wallNode = SKShapeNode(rect: rect, cornerRadius: 2)
        wallNode.fillColor = color
        wallNode.strokeColor = color.withAlphaComponent(0.6)
        wallNode.lineWidth = 1
        wallNode.position = worldPosition(for: GridPosition(col: col, row: row))
        wallNode.name = "wall"
        return wallNode
    }

    private func createEnemyHomeBorder(color: SKColor) -> SKShapeNode {
        // Find enemy home bounds
        guard let minCol = enemyHomePositions.map({ $0.col }).min(),
              let maxCol = enemyHomePositions.map({ $0.col }).max(),
              let minRow = enemyHomePositions.map({ $0.row }).min(),
              let maxRow = enemyHomePositions.map({ $0.row }).max() else {
            return SKShapeNode()
        }

        // Include door in bounds
        let doorRow = enemyDoorPosition.row

        let topLeft = worldPosition(for: GridPosition(col: minCol, row: max(maxRow, doorRow)))
        let bottomRight = worldPosition(for: GridPosition(col: maxCol, row: minRow))

        let width = bottomRight.x - topLeft.x + tileSize
        let height = topLeft.y - bottomRight.y + tileSize

        let rect = CGRect(
            x: topLeft.x - tileSize/2,
            y: bottomRight.y - tileSize/2,
            width: width,
            height: height
        )

        let borderNode = SKShapeNode(rect: rect, cornerRadius: 4)
        borderNode.fillColor = .clear
        borderNode.strokeColor = color.withAlphaComponent(0.5)
        borderNode.lineWidth = 2
        borderNode.name = "enemyHomeBorder"

        // Create door opening
        let doorPos = worldPosition(for: enemyDoorPosition)
        let doorNode = SKShapeNode(rectOf: CGSize(width: tileSize * 0.8, height: 4))
        doorNode.fillColor = color.withAlphaComponent(0.3)
        doorNode.strokeColor = .clear
        doorNode.position = CGPoint(x: doorPos.x, y: doorPos.y + tileSize/2)
        doorNode.name = "enemyDoor"
        borderNode.addChild(doorNode)

        return borderNode
    }
}

// MARK: - Int Clamped Extension

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
