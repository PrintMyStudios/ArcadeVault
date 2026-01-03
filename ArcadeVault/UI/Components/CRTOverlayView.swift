import SwiftUI

/// CRT effect overlay with scanlines and vignette
struct CRTOverlayView: View {
    @Environment(\.themeManager) private var themeManager

    var body: some View {
        let effects = themeManager.currentTheme.effects

        ZStack {
            // Scanlines
            if effects.scanlineOpacity > 0 {
                ScanlineEffect(opacity: effects.scanlineOpacity)
            }

            // Vignette
            if effects.vignetteIntensity > 0 {
                VignetteEffect(intensity: effects.vignetteIntensity)
            }
        }
        .allowsHitTesting(false)
    }
}

struct ScanlineEffect: View {
    let opacity: CGFloat

    var body: some View {
        Canvas { context, size in
            let lineHeight: CGFloat = 2
            let spacing: CGFloat = 2

            for y in stride(from: 0, to: size.height, by: lineHeight + spacing) {
                let rect = CGRect(x: 0, y: y, width: size.width, height: lineHeight)
                context.fill(Path(rect), with: .color(.black.opacity(opacity)))
            }
        }
    }
}

struct VignetteEffect: View {
    let intensity: CGFloat

    var body: some View {
        RadialGradient(
            colors: [
                .clear,
                .black.opacity(Double(intensity) * 0.5),
                .black.opacity(Double(intensity))
            ],
            center: .center,
            startRadius: 100,
            endRadius: 500
        )
    }
}
