import SwiftUI

extension Color {
    /// Initialize Color from hex string (e.g., "FF00FF" or "#FF00FF")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

extension View {
    /// Apply glow effect with given color and intensity
    @ViewBuilder
    func glow(color: Color, radius: CGFloat, intensity: CGFloat) -> some View {
        if intensity > 0 {
            self.shadow(color: color.opacity(Double(intensity)), radius: radius)
                .shadow(color: color.opacity(Double(intensity) * 0.5), radius: radius * 2)
        } else {
            self
        }
    }
}

extension CGPoint {
    /// Distance to another point
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }

    /// Linear interpolation to another point
    func lerp(to point: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (point.x - x) * t,
            y: y + (point.y - y) * t
        )
    }
}

extension CGFloat {
    /// Clamp value between min and max
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
