import Foundation

/// Centralized tuning constants
enum Constants {
    enum Animation {
        static let quick: Double = 0.15
        static let standard: Double = 0.25
        static let slow: Double = 0.4
    }

    enum Layout {
        static let tileMinWidth: CGFloat = 160
        static let tileMaxWidth: CGFloat = 200
        static let iconSize: CGFloat = 60
        static let hudHeight: CGFloat = 60
    }

    enum Game {
        static let defaultLives: Int = 3
        static let baseSpawnInterval: Double = 1.5
        static let minSpawnInterval: Double = 0.3
    }
}
