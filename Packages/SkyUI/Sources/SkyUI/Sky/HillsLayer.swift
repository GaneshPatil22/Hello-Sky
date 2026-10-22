import SkyCore
import SwiftUI

/// A dark ridge along the bottom, so the sky has somewhere to end.
///
/// Two ridges at different depths: the far one lighter and higher, the near one
/// darker. The profile is a sum of sines, seeded per place.
struct HillsLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize) {
        var generator = SeededGenerator(seed: snapshot.seed &+ Layout.seedOffset)

        for ridge in 0..<Layout.ridgeCount {
            let depth = Double(ridge) / Double(Layout.ridgeCount - 1)
            let baseline = size.height * (Layout.farBaseline + depth * Layout.baselineSpread)
            let amplitude = size.height * Layout.amplitude * (1 - depth * Layout.amplitudeFalloff)

            let path = ridgePath(
                in: size,
                baseline: baseline,
                amplitude: amplitude,
                generator: &generator
            )
            // Ridges are the horizon colour pushed towards black, so they stay
            // in the look rather than being a flat grey in every theme.
            let shade = snapshot.gradient.horizon
                .blended(towards: Layout.shadow, amount: Layout.farShade + depth * Layout.shadeSpread)
            context.fill(path, with: .color(shade.color))
        }
    }

    private func ridgePath(
        in size: CGSize,
        baseline: Double,
        amplitude: Double,
        generator: inout SeededGenerator
    ) -> Path {
        let firstFrequency = generator.next(in: Layout.firstFrequencyRange)
        let secondFrequency = generator.next(in: Layout.secondFrequencyRange)
        let firstPhase = generator.nextFraction() * .pi * 2
        let secondPhase = generator.nextFraction() * .pi * 2

        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height))
        for step in stride(from: 0.0, through: size.width, by: Layout.step) {
            let u = step / size.width
            let height = sin(u * firstFrequency + firstPhase)
                + Layout.secondWeight * sin(u * secondFrequency + secondPhase)
            path.addLine(to: CGPoint(x: step, y: baseline - height * amplitude))
        }
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()
        return path
    }
}

extension HillsLayer {
    private enum Layout {
        static let seedOffset: UInt64 = 0x4111_5000
        static let ridgeCount = 2
        static let farBaseline = 0.78
        static let baselineSpread = 0.12
        static let amplitude = 0.05
        static let amplitudeFalloff = 0.4
        static let step = 4.0
        static let firstFrequencyRange: ClosedRange<Double> = 3...6
        static let secondFrequencyRange: ClosedRange<Double> = 8...14
        static let secondWeight = 0.35
        static let shadow = SkyColor(hex: 0x000000)
        static let farShade = 0.55
        static let shadeSpread = 0.3
    }
}
