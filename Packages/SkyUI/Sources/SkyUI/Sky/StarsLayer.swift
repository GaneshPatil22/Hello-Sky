import SkyCore
import SwiftUI

/// Scattered points of light, placed once from the seed and twinkling slowly.
struct StarsLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize, motion: Double) {
        guard snapshot.starVisibility > 0 else { return }

        var generator = SeededGenerator(seed: snapshot.seed)
        let tint = snapshot.theme.starTint.color

        for index in 0..<Layout.count {
            let x = generator.nextFraction() * size.width
            // Kept to the upper part of the frame: the horizon band belongs to
            // the glow and the hills.
            let y = generator.nextFraction() * size.height * Layout.skyFraction
            let brightness = generator.next(in: Layout.brightnessRange)
            let radius = generator.next(in: Layout.radiusRange)
            let twinkleOffset = generator.nextFraction() * .pi * 2

            let twinkle = 1 - Layout.twinkleDepth
                + Layout.twinkleDepth * sin(motion * Layout.twinkleSpeed + twinkleOffset)
            let alpha = snapshot.starVisibility * brightness * twinkle

            guard alpha > Layout.invisibleBelow else { continue }
            let dot = Path(ellipseIn: CGRect(x: x - radius, y: y - radius,
                                             width: radius * 2, height: radius * 2))
            context.fill(dot, with: .color(tint.opacity(alpha)))
            _ = index
        }
    }
}

extension StarsLayer {
    private enum Layout {
        static let count = 420
        /// Stars fill the top four-fifths; below that is horizon.
        static let skyFraction = 0.8
        static let brightnessRange: ClosedRange<Double> = 0.3...1.0
        static let radiusRange: ClosedRange<Double> = 0.5...1.6
        /// How much a star dims and brightens, as a fraction of its brightness.
        static let twinkleDepth = 0.25
        static let twinkleSpeed = 0.7
        static let invisibleBelow = 0.02
    }
}
