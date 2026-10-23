import SkyCore
import SwiftUI

/// The halo around the sun, placed by its real azimuth and elevation.
struct SunGlowLayer: View {
    let snapshot: SkySnapshot

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let radius = max(size.width, size.height) * Layout.radiusFraction
            RadialGradient(
                colors: [tint.opacity(snapshot.sunGlow), tint.opacity(0)],
                center: .topLeading,
                startRadius: 0,
                endRadius: radius
            )
            .offset(x: position(in: size).x - size.width / 2,
                    y: position(in: size).y - size.height / 2)
            .blendMode(.screen)
            .allowsHitTesting(false)
        }
    }

    /// The horizon colour pushed towards white: a sun that belongs to the look.
    private var tint: Color {
        snapshot.gradient.horizon
            .blended(towards: Layout.highlight, amount: Layout.tintTowardsHighlight)
            .color
    }

    private func position(in size: CGSize) -> CGPoint {
        let across = SkySnapshot.across(hourAngle: snapshot.sun.hourAngle)
        return CGPoint(
            x: across * size.width,
            y: SkySnapshot.verticalPosition(elevation: snapshot.sun.elevation, in: size.height)
        )
    }
}

extension SunGlowLayer {
    private enum Layout {
        static let radiusFraction = 0.75
        static let highlight = SkyColor(hex: 0xFFF6E0)
        static let tintTowardsHighlight = 0.75
    }
}
