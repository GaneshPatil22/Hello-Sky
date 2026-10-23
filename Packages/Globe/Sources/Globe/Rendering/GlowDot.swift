import SwiftUI

/// A point of light: a bright core fading into a halo.
///
/// One drawing shared by the city lights on the night side and the lights
/// travelling along the arcs, so the globe has a single idea of what a light
/// looks like rather than two that slowly drift apart.
public enum GlowDot {
    public static func draw(
        in context: inout GraphicsContext,
        at point: CGPoint,
        radius: Double,
        colour: Color,
        brightness: Double = 1
    ) {
        guard brightness > Layout.invisibleBelow, radius > 0 else { return }

        let halo = CGRect(
            x: point.x - radius, y: point.y - radius,
            width: radius * 2, height: radius * 2
        )
        context.fill(
            Path(ellipseIn: halo),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: colour.opacity(brightness), location: 0),
                    .init(color: colour.opacity(brightness * Layout.midOpacity), location: Layout.midStop),
                    .init(color: colour.opacity(0), location: 1),
                ]),
                center: point,
                startRadius: 0,
                endRadius: radius
            )
        )
    }
}

extension GlowDot {
    private enum Layout {
        /// Holds the core bright before the falloff, which is what makes it
        /// read as a light rather than a soft blob.
        static let midStop = 0.32
        static let midOpacity = 0.55
        static let invisibleBelow = 0.02
    }
}
