import Foundation

/// Tuning constants for Test Range game
enum TestRangeConstants {
    // Player
    static let playerSize: CGFloat = 40
    static let playerSpeed: CGFloat = 0.15

    // Tokens
    static let tokenSize: CGFloat = 20
    static let tokenSpawnInterval: TimeInterval = 0.8
    static let tokenFallSpeed: TimeInterval = 3.0
    static let tokenPoints: Int = 10

    // Hazards
    static let hazardSize: CGFloat = 30
    static let initialHazardInterval: TimeInterval = 1.5
    static let minHazardInterval: TimeInterval = 0.4
    static let hazardIntervalDecrement: TimeInterval = 0.03
    static let hazardFallSpeed: TimeInterval = 2.5

    // Physics categories
    static let playerCategory: UInt32 = 0b0001
    static let tokenCategory: UInt32 = 0b0010
    static let hazardCategory: UInt32 = 0b0100
    static let boundaryCategory: UInt32 = 0b1000
}
