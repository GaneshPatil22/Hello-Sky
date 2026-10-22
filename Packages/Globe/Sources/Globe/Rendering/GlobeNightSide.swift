import SkyUI
import SwiftUI

/// The shadow over the half of the Earth facing away from the sun.
///
/// The edge of that shadow is a great circle, and a great circle seen from
/// outside projects to an ellipse — so the night side is a half-disc joined to
/// a half-ellipse whose width is how far the sun is in front of or behind the
/// globe. Drawing it that way gives the real curve of the terminator for free.
struct GlobeNightSide {
    let frame: GlobeFrame
    let style: GlobeStyle

    func draw(in context: inout GraphicsContext) {
        let radius = frame.radius
        var shadow = context
        shadow.clip(to: Path(ellipseIn: CGRect(
            x: frame.centre.x - radius, y: frame.centre.y - radius,
            width: radius * 2, height: radius * 2
        )))
        shadow.translateBy(x: frame.centre.x, y: frame.centre.y)
        // Turn so the sun lies along +x, which makes the terminator vertical
        // and the two halves easy to describe.
        shadow.rotate(by: .radians(atan2(Double(-frame.sunInView.y), Double(frame.sunInView.x))))

        let depth = Double(frame.sunInView.z)
        let halfWidth = max(abs(depth) * radius, Layout.thinnestEllipse)

        var path = Path()
        // The far half of the disc, away from the sun.
        path.addArc(center: .zero, radius: radius,
                    startAngle: .degrees(90), endAngle: .degrees(270),
                    clockwise: false)
        // The terminator itself: wider when the sun is in front of or behind
        // the globe, a straight line when it is exactly side on.
        path.addArc(center: .zero, radius: halfWidth,
                    startAngle: .degrees(270), endAngle: .degrees(90),
                    clockwise: depth < 0,
                    transform: CGAffineTransform(scaleX: 1, y: radius / halfWidth))
        path.closeSubpath()

        shadow.addFilter(.blur(radius: radius * Layout.softness))
        shadow.fill(path, with: .color(style.nightShade.color.opacity(Layout.opacity)))
    }
}

extension GlobeNightSide {
    private enum Layout {
        static let opacity = 0.93
        /// Blurs the edge so the terminator is a band, not a cut.
        static let softness = 0.028
        static let thinnestEllipse = 0.01
    }
}
