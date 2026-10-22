import SkyCore
import SkyUI
import SwiftUI
import simd

/// Points of light on the night side, where the world's cities are.
struct GlobeCityLights {
    let frame: GlobeFrame
    let style: GlobeStyle

    func draw(in context: inout GraphicsContext) {
        for city in Self.cities {
            let (position, facing) = frame.project(city)
            guard facing > Layout.visibleAbove else { continue }

            // Brightest well into the night, gone before the terminator.
            let light = frame.light(at: city)
            let strength = GlobeLand.ramp(light, from: Layout.brightestBelow, to: Layout.goneAbove)
            let alpha = (1 - strength) * Layout.opacity * (Layout.depthFloor + Layout.depthRange * facing)
            guard alpha > Layout.invisibleBelow else { continue }

            let size = frame.radius * Layout.sizeFraction
            let halo = CGRect(x: position.x - size, y: position.y - size, width: size * 2, height: size * 2)
            context.fill(
                Path(ellipseIn: halo),
                with: .radialGradient(
                    Gradient(colors: [style.cityLights.color.opacity(alpha), .clear]),
                    center: position, startRadius: 0, endRadius: size
                )
            )
        }
    }

    /// Where the lights go. The catalogue is the app's own city list, so the
    /// lit points are places someone could actually be following.
    static let cities: [SIMD3<Float>] = CityLightPlaces.coordinates.map(GlobeGeometry.vector(for:))
}

extension GlobeCityLights {
    private enum Layout {
        static let visibleAbove = 0.03
        /// Full strength at this light level and below.
        static let brightestBelow = -0.22
        /// Faded out by here, before the day side begins.
        static let goneAbove = 0.08
        static let opacity = 0.85
        static let depthFloor = 0.5
        static let depthRange = 0.5
        static let sizeFraction = 0.035
        static let invisibleBelow = 0.02
    }
}
