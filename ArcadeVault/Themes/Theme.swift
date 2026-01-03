import SwiftUI

/// A complete theme definition with all visual tokens
struct Theme: Identifiable, Equatable {
    let id: String
    let displayName: String
    let palette: ThemePalette
    let typography: ThemeTypography
    let effects: ThemeEffects
    let layout: ThemeLayout
}

/// Color palette tokens
struct ThemePalette: Equatable {
    let background: Color
    let backgroundSecondary: Color
    let foreground: Color
    let foregroundSecondary: Color
    let accent: Color
    let accentSecondary: Color
    let danger: Color
    let success: Color
    let warning: Color
}

/// Typography tokens
struct ThemeTypography: Equatable {
    let titleFont: Font
    let headlineFont: Font
    let bodyFont: Font
    let captionFont: Font
    let monoFont: Font

    /// Title font for display in SpriteKit (name + size)
    var titleFontName: String { "System" }
    var titleFontSize: CGFloat { 32 }
    var scoreFontName: String { "Menlo-Bold" }
    var scoreFontSize: CGFloat { 24 }
}

/// Visual effects tokens
struct ThemeEffects: Equatable {
    let glowIntensity: CGFloat
    let glowRadius: CGFloat
    let scanlineOpacity: CGFloat
    let vignetteIntensity: CGFloat
    let cornerRadius: CGFloat
}

/// Layout spacing tokens
struct ThemeLayout: Equatable {
    let gridSpacing: CGFloat
    let tilePadding: CGFloat
    let buttonPadding: EdgeInsets
    let contentPadding: EdgeInsets
}

// MARK: - All Available Themes

extension Theme {
    static let allThemes: [Theme] = [
        .neonCRT,
        .vectorArcade,
        .eightBitCandy
    ]

    static func theme(for id: String) -> Theme {
        allThemes.first { $0.id == id } ?? .neonCRT
    }
}
