import SkyCore
import SkyUI
import SwiftUI
import simd

/// The Earth, drawn as dotted continents over a lit ocean.
///
/// Drawn rather than modelled: the whole planet is a 32 KB land mask and a
/// scatter of points, which costs nothing to ship and restyles with the look.
public struct GlobeCanvasView: View {
    let camera: GlobeCamera
    let date: Date
    let quality: GlobeQuality

    @Environment(\.theme) private var theme

    public init(camera: GlobeCamera, date: Date, quality: GlobeQuality = .high) {
        self.camera = camera
        self.date = date
        self.quality = quality
    }

    public var body: some View {
        Canvas(opaque: false) { context, size in
            let frame = GlobeFrame(camera: camera, date: date, size: size)
            let style = theme.globe

            GlobeAtmosphere(frame: frame, style: style).draw(in: &context)
            GlobeOcean(frame: frame, style: style).draw(in: &context)
            GlobeNightSide(frame: frame, style: style).draw(in: &context)
            GlobeGraticule(frame: frame, style: style).draw(in: &context)
            GlobeLand(frame: frame, style: style, quality: quality).draw(in: &context)
            GlobeCityLights(frame: frame, style: style).draw(in: &context)
        }
        .accessibilityLabel("Globe")
        .accessibilityHint("Drag to turn the Earth")
    }
}
