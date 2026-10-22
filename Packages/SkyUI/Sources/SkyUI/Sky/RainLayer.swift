import SkyCore
import SwiftUI

/// Streaks of rain, as many and as fast as the intensity says.
struct RainLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize, motion: Double) {
        guard snapshot.rain > Layout.invisibleBelow else { return }

        var generator = SeededGenerator(seed: snapshot.seed &+ Layout.seedOffset)
        let count = Int(Double(Layout.maximumDrops) * snapshot.rain)
        let tint = snapshot.gradient.top
            .blended(towards: Layout.highlight, amount: Layout.tintTowardsHighlight)
            .color.opacity(Layout.opacity * snapshot.rain)

        for drop in 0..<count {
            let x = generator.nextFraction() * size.width
            let speed = generator.next(in: Layout.speedRange) * size.height
            let length = generator.next(in: Layout.lengthRange) * size.height
            let start = generator.nextFraction() * size.height

            // Each drop falls, wraps, and falls again, so the rain never ends.
            let y = (start + motion * speed).truncatingRemainder(dividingBy: size.height + length) - length

            var streak = Path()
            streak.move(to: CGPoint(x: x, y: y))
            streak.addLine(to: CGPoint(x: x - Layout.slant * length, y: y + length))
            context.stroke(streak, with: .color(tint), lineWidth: Layout.width)
            _ = drop
        }
    }
}

extension RainLayer {
    private enum Layout {
        static let seedOffset: UInt64 = 0x7A14_0000
        static let maximumDrops = 160
        static let invisibleBelow = 0.02
        /// Fractions of the frame height travelled per second.
        static let speedRange: ClosedRange<Double> = 0.9...1.6
        static let lengthRange: ClosedRange<Double> = 0.03...0.08
        static let slant = 0.18
        static let width = 1.0
        static let opacity = 0.55
        static let highlight = SkyColor(hex: 0xFFFFFF)
        static let tintTowardsHighlight = 0.7
    }
}
