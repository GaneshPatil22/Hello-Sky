import SkyCore
import SwiftUI

/// The moon, drawn at its real phase and placed by its real elevation.
///
/// The lit part is the disc minus a shifted circle, which is what a phase
/// actually is, rather than a crescent drawn by eye.
struct MoonLayer {
    let snapshot: SkySnapshot

    func draw(in context: inout GraphicsContext, size: CGSize) {
        let visibility = snapshot.moonVisibility
        guard visibility > 0 else { return }

        let radius = min(size.width, size.height) * Layout.radiusFraction
        let centre = position(in: size, radius: radius)
        let disc = CGRect(x: centre.x - radius, y: centre.y - radius,
                          width: radius * 2, height: radius * 2)
        let tint = snapshot.theme.starTint.color

        // The glow around it, which is most of what makes a moon read as lit
        // rather than as a pale circle.
        let halo = radius * Layout.haloScale
        context.fill(
            Path(ellipseIn: CGRect(x: centre.x - halo, y: centre.y - halo,
                                   width: halo * 2, height: halo * 2)),
            with: .radialGradient(
                Gradient(colors: [
                    tint.opacity(visibility * snapshot.moonPhase.illumination * Layout.haloOpacity),
                    tint.opacity(0),
                ]),
                center: centre, startRadius: radius * Layout.haloInner, endRadius: halo
            )
        )

        var shaded = context
        shaded.clip(to: Path(ellipseIn: disc))
        shaded.fill(Path(ellipseIn: disc), with: .color(tint.opacity(visibility)))
        drawCraters(in: &shaded, centre: centre, radius: radius, tint: tint, visibility: visibility)

        // The terminator: a circle of the sky's own colour, offset by how far
        // through the cycle the moon is. At full it misses the disc entirely.
        let illumination = snapshot.moonPhase.illumination
        let shadowOffset = radius * 2 * (snapshot.moonPhase.isWaxing ? -1 : 1) * (1 - illumination)
        let shadow = disc.offsetBy(dx: shadowOffset, dy: 0)
        // Only as opaque as the lit side is bright, so the unlit part never
        // reads darker than the sky it sits on.
        shaded.fill(Path(ellipseIn: shadow),
                    with: .color(snapshot.gradient.top.color.opacity(visibility)))
    }

    /// A few grey patches, placed from the place's own seed so a city's moon
    /// always looks the same.
    private func drawCraters(
        in context: inout GraphicsContext,
        centre: CGPoint,
        radius: Double,
        tint: Color,
        visibility: Double
    ) {
        var generator = SeededGenerator(seed: snapshot.seed &+ Layout.seedOffset)
        for _ in 0..<Layout.craterCount {
            let angle = generator.nextFraction() * 2 * .pi
            let distance = generator.next(in: Layout.craterDistance) * radius
            let size = generator.next(in: Layout.craterSize) * radius
            let spot = CGRect(
                x: centre.x + cos(angle) * distance - size,
                y: centre.y + sin(angle) * distance - size,
                width: size * 2, height: size * 2
            )
            context.fill(
                Path(ellipseIn: spot),
                with: .color(snapshot.gradient.top.color.opacity(visibility * Layout.craterOpacity))
            )
        }
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
        static let haloScale = 2.6
        static let haloInner = 0.7
        static let haloOpacity = 0.4
        static let seedOffset: UInt64 = 0x3100_0CAE
        static let craterCount = 5
        static let craterDistance: ClosedRange<Double> = 0.1...0.55
        static let craterSize: ClosedRange<Double> = 0.1...0.22
        static let craterOpacity = 0.28
    }
}
