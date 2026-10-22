import SkyUI
import SwiftUI

/// The sea: a gradient whose bright point sits where the sun is.
struct GlobeOcean {
    let frame: GlobeFrame
    let style: GlobeStyle

    func draw(in context: inout GraphicsContext) {
        let disc = Path(ellipseIn: CGRect(
            x: frame.centre.x - frame.radius, y: frame.centre.y - frame.radius,
            width: frame.radius * 2, height: frame.radius * 2
        ))
        // Offsetting the gradient's centre towards the sun is what reads as a
        // sphere lit from one side rather than a flat blue circle.
        let lit = CGPoint(
            x: frame.centre.x + Double(frame.sunInView.x) * frame.radius * Layout.sunPull,
            y: frame.centre.y - Double(frame.sunInView.y) * frame.radius * Layout.sunPull
        )
        context.fill(
            disc,
            with: .radialGradient(
                Gradient(colors: [style.oceanLit.color, style.oceanDeep.color]),
                center: lit,
                startRadius: frame.radius * Layout.innerRadius,
                endRadius: frame.radius * Layout.outerRadius
            )
        )
    }
}

extension GlobeOcean {
    private enum Layout {
        static let sunPull = 0.35
        static let innerRadius = 0.05
        static let outerRadius = 1.15
    }
}
