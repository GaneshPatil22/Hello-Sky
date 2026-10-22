import SkyUI
import SwiftUI

/// The halo of air around the Earth's edge.
struct GlobeAtmosphere {
    let frame: GlobeFrame
    let style: GlobeStyle

    func draw(in context: inout GraphicsContext) {
        let outer = frame.radius * Layout.outerScale
        let rect = CGRect(x: frame.centre.x - outer, y: frame.centre.y - outer,
                          width: outer * 2, height: outer * 2)
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: .clear, location: Layout.innerStop),
                    .init(color: style.atmosphere.color.opacity(Layout.opacity), location: Layout.glowStop),
                    .init(color: .clear, location: 1),
                ]),
                center: frame.centre,
                startRadius: 0,
                endRadius: outer
            )
        )
    }
}

extension GlobeAtmosphere {
    private enum Layout {
        static let outerScale = 1.45
        /// The glow starts just inside the limb and fades outward.
        static let innerStop = 0.6
        static let glowStop = 0.70
        static let opacity = 0.33
    }
}
