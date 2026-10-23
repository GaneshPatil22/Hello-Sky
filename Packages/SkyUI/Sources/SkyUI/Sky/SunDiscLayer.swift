import SkyCore
import SwiftUI

/// The sun itself: a disc with the air glowing around it.
///
/// Drawn as well as the halo, because a sunrise without a visible sun reads as
/// a coloured wash rather than as a sun coming up.
struct SunDiscLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize) {
        let elevation = snapshot.sun.elevation
        guard elevation > Layout.visibleAbove else { return }

        // Fades in across the horizon rather than popping into view.
        let presence = SkySnapshot.ramp(elevation, from: Layout.visibleAbove, to: Layout.fullyUpAbove)
        let hidden = snapshot.cloudCover.total * Layout.cloudHides
        let strength = presence * (1 - hidden)
        guard strength > Layout.invisibleBelow else { return }

        let centre = position(in: size)
        let radius = min(size.width, size.height) * Layout.radiusFraction
        let tint = snapshot.gradient.horizon
            .blended(towards: Layout.core, amount: Layout.tintTowardsCore)
            .color

        // A wide corona first, then the disc, so the edge is light rather than
        // a cut-out circle pasted on the sky.
        let halo = radius * Layout.haloScale
        context.fill(
            Path(ellipseIn: CGRect(x: centre.x - halo, y: centre.y - halo,
                                   width: halo * 2, height: halo * 2)),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: tint.opacity(strength * Layout.haloOpacity), location: 0),
                    .init(color: tint.opacity(strength * Layout.haloMidOpacity), location: Layout.haloMidStop),
                    .init(color: tint.opacity(0), location: 1),
                ]),
                center: centre, startRadius: 0, endRadius: halo
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius,
                                   width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    Layout.core.color.opacity(strength),
                    tint.opacity(strength * Layout.rimOpacity),
                ]),
                center: centre, startRadius: 0, endRadius: radius
            )
        )
    }

    /// Azimuth places the sun across the frame, elevation up it.
    private func position(in size: CGSize) -> CGPoint {
        let across = (snapshot.sun.azimuth / 360).clamped(to: 0...1)
        let up = (snapshot.sun.elevation / Layout.elevationAtTop).clamped(to: 0...1)
        return CGPoint(
            x: across * size.width,
            y: size.height * Layout.horizonFraction * (1 - up)
        )
    }
}

extension SunDiscLayer {
    private enum Layout {
        /// Shows a little before the sun clears the horizon, as it does.
        static let visibleAbove = -2.5
        static let fullyUpAbove = 2.0
        static let elevationAtTop = 70.0
        static let horizonFraction = 0.78
        static let radiusFraction = 0.062
        static let haloScale = 3.4
        static let haloOpacity = 0.5
        static let haloMidOpacity = 0.16
        static let haloMidStop = 0.3
        static let rimOpacity = 0.75
        static let cloudHides = 0.7
        static let invisibleBelow = 0.02
        static let tintTowardsCore = 0.55
        static let core = SkyColor(hex: 0xFFF3D0)
    }
}
