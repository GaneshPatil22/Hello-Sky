import SkyCore
import SwiftUI

/// A field of stars on its own, for use behind the globe.
///
/// The sky renderer draws its own stars from a `SkySnapshot`; this is the same
/// idea with nothing else attached, so deep space is not a flat colour.
public struct StarfieldView: View {
    let seed: UInt64
    let tint: SkyColor

    public init(seed: UInt64 = Defaults.seed, tint: SkyColor = Defaults.tint) {
        self.seed = seed
        self.tint = tint
    }

    public var body: some View {
        Canvas(opaque: false) { context, size in
            var generator = SeededGenerator(seed: seed)
            for _ in 0..<Layout.count {
                let x = generator.nextFraction() * size.width
                let y = generator.nextFraction() * size.height
                let radius = generator.next(in: Layout.radiusRange)
                let alpha = generator.next(in: Layout.alphaRange)

                let dot = Path(ellipseIn: CGRect(x: x - radius, y: y - radius,
                                                 width: radius * 2, height: radius * 2))
                context.fill(dot, with: .color(tint.color.opacity(alpha)))
            }
        }
        .accessibilityHidden(true)
    }
}

extension StarfieldView {
    public enum Defaults {
        public static let seed: UInt64 = 0x5747_5F53_4B59
        public static let tint = SkyColor(hex: 0xFFFFFF)
    }

    private enum Layout {
        static let count = 260
        static let radiusRange: ClosedRange<Double> = 0.3...1.2
        static let alphaRange: ClosedRange<Double> = 0.12...0.75
    }
}
