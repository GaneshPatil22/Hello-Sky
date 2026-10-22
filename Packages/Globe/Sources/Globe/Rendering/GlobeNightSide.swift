import SkyUI
import SwiftUI
import simd

/// The shadow over the half of the Earth facing away from the sun.
struct GlobeNightSide {
    let frame: GlobeFrame
    let style: GlobeStyle

    func draw(in context: inout GraphicsContext) {
        var shadow = context
        shadow.clip(to: Self.disc(centre: frame.centre, radius: frame.radius))
        shadow.addFilter(.blur(radius: frame.radius * Layout.softness))
        shadow.fill(
            Self.nightRegion(frame: frame),
            with: .color(style.nightShade.color.opacity(Layout.opacity))
        )
    }

    static func disc(centre: CGPoint, radius: Double) -> Path {
        Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius,
                               width: radius * 2, height: radius * 2))
    }

    /// The night half, in screen coordinates.
    ///
    /// Measure a point on the near side in two directions: `a` along the sun's
    /// direction across the screen, `b` across it. Its surface normal is then
    /// `(a, b, √(1 − a² − b²))` in that basis, and it is in darkness when that
    /// normal points away from the sun. Working that through leaves one line:
    ///
    ///     night  ⟺  a < −sz · √(1 − b²)
    ///
    /// where `sz` is how far the sun lies in front of the globe. So the
    /// terminator is traced directly from the same vectors the continents are
    /// shaded by, which is what keeps the shadow and the land in step.
    static func nightRegion(frame: GlobeFrame) -> Path {
        let radius = frame.radius
        let sun = frame.sunInView
        let depth = Double(sun.z)
        let across = hypot(Double(sun.x), Double(sun.y))

        // Sun dead centre or dead behind: no terminator is visible at all.
        guard across > Layout.sunOnAxis else {
            return depth > 0 ? Path() : disc(centre: frame.centre, radius: radius)
        }

        let direction = CGPoint(x: Double(sun.x) / across, y: Double(sun.y) / across)
        var path = Path()

        // The terminator, swept from one limb crossing to the other.
        for step in 0...Layout.steps {
            let angle = -Double.pi / 2 + Double(step) / Double(Layout.steps) * .pi
            let b = sin(angle)
            let a = -depth * cos(angle)
            let point = screenPoint(a: a, b: b, direction: direction, frame: frame)
            if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }

        // Back around the limb, the long way, which is the side away from the sun.
        for step in 0...Layout.steps {
            let angle = .pi / 2 + Double(step) / Double(Layout.steps) * .pi
            let point = screenPoint(a: cos(angle), b: sin(angle), direction: direction, frame: frame)
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    /// Turns sun-aligned coordinates back into a position on screen.
    private static func screenPoint(
        a: Double,
        b: Double,
        direction: CGPoint,
        frame: GlobeFrame
    ) -> CGPoint {
        let x = a * direction.x - b * direction.y
        let y = a * direction.y + b * direction.x
        return CGPoint(
            x: frame.centre.x + frame.radius * x,
            y: frame.centre.y - frame.radius * y
        )
    }
}

extension GlobeNightSide {
    enum Layout {
        static let opacity = 0.93
        /// Blurs the edge so the terminator is a band, not a cut.
        static let softness = 0.025
        static let steps = 96
        /// Below this the sun is effectively on the view axis.
        static let sunOnAxis = 0.004
    }
}
