import SkyCore
import SwiftUI

/// Soft cloud shapes drifting across the sky.
///
/// Each cloud is a handful of overlapping ellipses, which reads as a cloud at
/// a glance and costs almost nothing to draw.
struct CloudsLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize, motion: Double) {
        let cover = snapshot.cloudCover.total
        guard cover > Layout.invisibleBelow else { return }

        var generator = SeededGenerator(seed: snapshot.seed &+ Layout.seedOffset)
        let count = Int((Double(Layout.maximumCount) * cover).rounded())
        // Clouds take the sky's own colours rather than white, so they sit in
        // the palette at every hour instead of glaring at night.
        let tint = snapshot.gradient.horizon.blended(
            towards: snapshot.gradient.top,
            amount: Layout.tintTowardsTop
        ).color

        for index in 0..<max(count, 1) {
            let depth = generator.nextFraction()
            let scale = Layout.scaleRange.lowerBound
                + depth * (Layout.scaleRange.upperBound - Layout.scaleRange.lowerBound)
            let width = size.width * Layout.widthFraction * scale
            let height = width * Layout.aspect

            // Nearer clouds drift faster, which reads as depth.
            let speed = Layout.baseSpeed * (Layout.speedDepthFloor + depth)
            let startX = generator.nextFraction() * (size.width + width * 2)
            let x = (startX + motion * speed).truncatingRemainder(dividingBy: size.width + width * 2) - width
            let y = generator.next(in: Layout.heightRange) * size.height

            let opacity = Layout.opacityFloor + cover * Layout.opacityRange
            drawPuffs(in: &context, at: CGPoint(x: x, y: y), width: width, height: height,
                      tint: tint.opacity(opacity * (Layout.depthOpacityFloor + depth * Layout.depthOpacityRange)),
                      generator: &generator)
            _ = index
        }
    }

    private func drawPuffs(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        width: Double,
        height: Double,
        tint: Color,
        generator: inout SeededGenerator
    ) {
        for puff in 0..<Layout.puffsPerCloud {
            let offsetX = (Double(puff) / Double(Layout.puffsPerCloud - 1) - 0.5) * width
            let puffWidth = width * generator.next(in: Layout.puffWidthRange)
            let puffHeight = height * generator.next(in: Layout.puffHeightRange)
            let rect = CGRect(
                x: centre.x + offsetX - puffWidth / 2,
                y: centre.y - puffHeight / 2,
                width: puffWidth,
                height: puffHeight
            )
            context.fill(Path(ellipseIn: rect), with: .color(tint))
        }
    }
}

extension CloudsLayer {
    private enum Layout {
        static let seedOffset: UInt64 = 0x51ED_C10D
        static let maximumCount = 9
        static let invisibleBelow = 0.02
        static let widthFraction = 0.42
        static let aspect = 0.30
        static let scaleRange: ClosedRange<Double> = 0.55...1.4
        static let heightRange: ClosedRange<Double> = 0.08...0.62
        static let puffsPerCloud = 5
        static let puffWidthRange: ClosedRange<Double> = 0.35...0.6
        static let puffHeightRange: ClosedRange<Double> = 0.6...1.0
        /// Points a second at full depth.
        static let baseSpeed = 6.0
        static let speedDepthFloor = 0.35
        static let opacityFloor = 0.18
        static let opacityRange = 0.5
        static let depthOpacityFloor = 0.5
        static let depthOpacityRange = 0.5
        static let tintTowardsTop = 0.35
    }
}
