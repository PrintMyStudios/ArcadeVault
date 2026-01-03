import SwiftUI

/// Procedurally-drawn game icons
struct ProceduralIconView: View {
    let style: GameIconStyle
    let size: CGFloat
    let accentColor: Color
    let secondaryColor: Color

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2 - 4

            switch style {
            case .testRange:
                drawTestRange(context: context, center: center, radius: radius)
            case .mazeChase:
                drawMazeChase(context: context, center: center, radius: radius)
            case .fixedShooter:
                drawFixedShooter(context: context, center: center, radius: radius)
            case .platformer:
                drawPlatformer(context: context, center: center, radius: radius)
            }
        }
        .frame(width: size, height: size)
    }

    private func drawTestRange(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Crosshair / target
        let ringRadius = radius * 0.8

        // Outer ring
        var outerRing = Path()
        outerRing.addArc(center: center, radius: ringRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.stroke(outerRing, with: .color(accentColor), lineWidth: 2)

        // Inner ring
        var innerRing = Path()
        innerRing.addArc(center: center, radius: ringRadius * 0.5, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.stroke(innerRing, with: .color(secondaryColor), lineWidth: 2)

        // Crosshairs
        var crosshair = Path()
        crosshair.move(to: CGPoint(x: center.x - ringRadius, y: center.y))
        crosshair.addLine(to: CGPoint(x: center.x + ringRadius, y: center.y))
        crosshair.move(to: CGPoint(x: center.x, y: center.y - ringRadius))
        crosshair.addLine(to: CGPoint(x: center.x, y: center.y + ringRadius))
        context.stroke(crosshair, with: .color(accentColor), lineWidth: 2)

        // Center dot
        var dot = Path()
        dot.addArc(center: center, radius: 4, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.fill(dot, with: .color(secondaryColor))
    }

    private func drawMazeChase(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Maze grid
        let gridSize = radius * 0.4
        let startX = center.x - gridSize * 1.5
        let startY = center.y - gridSize * 1.5

        var maze = Path()

        // Draw grid lines
        for i in 0...3 {
            let offset = CGFloat(i) * gridSize
            maze.move(to: CGPoint(x: startX + offset, y: startY))
            maze.addLine(to: CGPoint(x: startX + offset, y: startY + gridSize * 3))

            maze.move(to: CGPoint(x: startX, y: startY + offset))
            maze.addLine(to: CGPoint(x: startX + gridSize * 3, y: startY + offset))
        }
        context.stroke(maze, with: .color(secondaryColor.opacity(0.5)), lineWidth: 1)

        // Player dot
        var playerDot = Path()
        playerDot.addArc(center: CGPoint(x: startX + gridSize * 0.5, y: startY + gridSize * 0.5),
                         radius: gridSize * 0.3,
                         startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.fill(playerDot, with: .color(accentColor))

        // Ghost dots
        let ghostPositions = [
            CGPoint(x: startX + gridSize * 2.5, y: startY + gridSize * 0.5),
            CGPoint(x: startX + gridSize * 1.5, y: startY + gridSize * 2.5)
        ]
        for pos in ghostPositions {
            var ghost = Path()
            ghost.addArc(center: pos, radius: gridSize * 0.25, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.fill(ghost, with: .color(secondaryColor))
        }
    }

    private func drawFixedShooter(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Ship at bottom
        let shipY = center.y + radius * 0.5
        var ship = Path()
        ship.move(to: CGPoint(x: center.x, y: shipY - radius * 0.3))
        ship.addLine(to: CGPoint(x: center.x - radius * 0.2, y: shipY))
        ship.addLine(to: CGPoint(x: center.x + radius * 0.2, y: shipY))
        ship.closeSubpath()
        context.fill(ship, with: .color(accentColor))

        // Laser beam
        var laser = Path()
        laser.move(to: CGPoint(x: center.x, y: shipY - radius * 0.3))
        laser.addLine(to: CGPoint(x: center.x, y: center.y - radius * 0.4))
        context.stroke(laser, with: .color(secondaryColor), lineWidth: 2)

        // Enemy squares at top
        let enemyY = center.y - radius * 0.5
        let enemySize = radius * 0.2
        for i in -1...1 {
            let x = center.x + CGFloat(i) * radius * 0.4
            let rect = CGRect(x: x - enemySize/2, y: enemyY - enemySize/2, width: enemySize, height: enemySize)
            context.fill(Path(rect), with: .color(secondaryColor))
        }
    }

    private func drawPlatformer(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Platforms
        let platformHeight: CGFloat = 4
        let platforms = [
            CGRect(x: center.x - radius * 0.8, y: center.y + radius * 0.4, width: radius * 0.6, height: platformHeight),
            CGRect(x: center.x + radius * 0.2, y: center.y, width: radius * 0.6, height: platformHeight),
            CGRect(x: center.x - radius * 0.4, y: center.y - radius * 0.4, width: radius * 0.6, height: platformHeight)
        ]

        for platform in platforms {
            context.fill(Path(platform), with: .color(secondaryColor))
        }

        // Ladder
        var ladder = Path()
        let ladderX = center.x + radius * 0.3
        ladder.move(to: CGPoint(x: ladderX - 6, y: center.y + radius * 0.4))
        ladder.addLine(to: CGPoint(x: ladderX - 6, y: center.y))
        ladder.move(to: CGPoint(x: ladderX + 6, y: center.y + radius * 0.4))
        ladder.addLine(to: CGPoint(x: ladderX + 6, y: center.y))
        // Rungs
        for i in 0...3 {
            let y = center.y + radius * 0.4 - CGFloat(i) * radius * 0.1
            ladder.move(to: CGPoint(x: ladderX - 6, y: y))
            ladder.addLine(to: CGPoint(x: ladderX + 6, y: y))
        }
        context.stroke(ladder, with: .color(accentColor.opacity(0.7)), lineWidth: 2)

        // Player figure
        var player = Path()
        player.addArc(center: CGPoint(x: center.x - radius * 0.5, y: center.y + radius * 0.3),
                      radius: radius * 0.12,
                      startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.fill(player, with: .color(accentColor))
    }
}
