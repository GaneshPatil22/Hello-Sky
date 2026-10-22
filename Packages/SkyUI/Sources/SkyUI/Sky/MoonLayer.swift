import SkyCore
import SwiftUI

/// The moon, drawn at its real phase and placed by its real elevation.
///
/// The lit part is the disc minus a shifted circle, which is what a phase
/// actually is, rather than a crescent drawn by eye.
struct MoonLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize) {
        guard snapshot.isMoonVisible else { return }

        let radius = min(size.width, size.height) * Layout.radiusFraction
        let centre = position(in: size, radius: radius)
        let disc = CGRect(x: centre.x - radius, y: centre.y - radius,
                          width: radius * 2, height: radius * 2)
        let tint = snapshot.theme.starTint.color.opacity(snapshot.starVisibility)

        var shaded = context
        shaded.clip(to: Path(ellipseIn: disc))
        shaded.fill(Path(ellipseIn: disc), with: .color(tint))

        // The terminator: a circle of the sky's own colour, offset by how far
        // through the cycle the moon is. At full it misses the disc entirely.
        let illumination = snapshot.moonPhase.illumination
        let shadowOffset = radius * 2 * (snapshot.moonPhase.isWaxing ? -1 : 1) * (1 - illumination)
        let shadow = disc.offsetBy(dx: shadowOffset, dy: 0)
        shaded.fill(Path(ellipseIn: shadow), with: .color(snapshot.gradient.top.color))
    }

    /// Azimuth places the moon across the frame, elevation up it.
    private func position(in size: CGSize, radius: Double) -> CGPoint {
        let across = (snapshot.moon.azimuth / 360).clamped(to: 0...1)
        let up = (snapshot.moon.elevation / Layout.elevationAtTop).clamped(to: 0...1)
        return CGPoint(
            x: radius + across * (size.width - radius * 2),
            y: size.height * Layout.horizonFraction * (1 - up) + radius
        )
    }
}

extension MoonLayer {
    private enum Layout {
        static let radiusFraction = 0.055
        /// An elevation this high puts the moon at the top of the frame.
        static let elevationAtTop = 70.0
        static let horizonFraction = 0.72
    }
}
