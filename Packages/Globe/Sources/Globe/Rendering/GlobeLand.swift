import SkyUI
import SwiftUI
import simd

/// The continents, as dots shaded by how much daylight each one is getting.
///
/// Dots are batched by shade: one path per band rather than one fill per dot,
/// which is the difference between a few draws and several thousand.
struct GlobeLand {
    let frame: GlobeFrame
    let style: GlobeStyle
    let quality: GlobeQuality

    func draw(in context: inout GraphicsContext) {
        var bands = [Path](repeating: Path(), count: Layout.bandCount)
        let dotSize = frame.radius * Layout.dotFraction

        for point in GlobeDotField.points(for: quality) {
            let (position, facing) = frame.project(point)
            guard facing > Layout.visibleAbove else { continue }

            let light = frame.light(at: point)
            let shade = Self.ramp(light, from: Layout.darkestLight, to: Layout.brightestLight)
            let band = min(Int(shade * Double(Layout.bandCount)), Layout.bandCount - 1)

            // Dots nearer the middle of the disc face us more squarely, so they
            // read slightly larger; it is what gives the scatter its curve.
            let size = dotSize * (Layout.sizeFloor + Layout.sizeDepth * facing)
            bands[band].addEllipse(in: CGRect(
                x: position.x - size / 2, y: position.y - size / 2,
                width: size, height: size
            ))
        }

        for (index, band) in bands.enumerated() where !band.isEmpty {
            let light = (Double(index) + 0.5) / Double(Layout.bandCount)
            context.fill(band, with: .color(style.landShade(light: light).color))
        }
    }

    static func ramp(_ value: Double, from: Double, to: Double) -> Double {
        guard from != to else { return value >= to ? 1 : 0 }
        return min(max((value - from) / (to - from), 0), 1)
    }
}

extension GlobeLand {
    enum Layout {
        /// Ten shades is enough for the terminator to look like a gradient.
        static let bandCount = 10
        static let dotFraction = 0.017
        /// Just inside the limb, so dots do not smear along the edge.
        static let visibleAbove = 0.02
        /// The light levels the shading spans: a little past the terminator
        /// into the night, up to midday.
        static let darkestLight = -0.16
        static let brightestLight = 0.5
        static let sizeFloor = 0.5
        static let sizeDepth = 0.8
    }
}
