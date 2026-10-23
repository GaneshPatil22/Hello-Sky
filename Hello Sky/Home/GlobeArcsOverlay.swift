import Globe
import SkyCore
import SkyUI
import SwiftUI
import simd

/// The arcs from home out to everyone else, with a dot travelling along each.
///
/// Every arc and every dot is the same colour on purpose: the lines say who you
/// follow, the rings around the avatars say how they are. Mixing the two would
/// make the globe a chart of statuses rather than of people.
struct GlobeArcsOverlay: View {
    let home: Person?
    let people: [Person]
    let camera: GlobeCamera
    let elapsed: Double

    @Environment(\.theme) private var theme

    var body: some View {
        Canvas(opaque: false) { context, size in
            guard let home else { return }
            let frame = GlobeFrame(camera: camera, date: .now, size: size)

            for person in people where person.id != home.id {
                let arc = GlobeArc(from: home.place.coordinate, to: person.place.coordinate)
                draw(arc, in: &context, frame: frame)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func draw(_ arc: GlobeArc, in context: inout GraphicsContext, frame: GlobeFrame) {
        let projected = arc.points.map { project($0, in: frame) }

        var path = Path()
        var isDrawing = false
        for point in projected {
            guard let point else {
                isDrawing = false
                continue
            }
            if isDrawing { path.addLine(to: point) } else { path.move(to: point); isDrawing = true }
        }
        context.stroke(
            path,
            with: .color(tint.opacity(Layout.lineOpacity)),
            style: StrokeStyle(lineWidth: Layout.lineWidth, lineCap: .round, dash: Layout.dash)
        )

        guard arc.length > 0 else { return }
        // Constant speed, so a longer arc simply takes longer: the dots fall
        // out of step on their own and stop looking like a marching band.
        let period = arc.length / Layout.dotSpeed
        let progress = (elapsed.truncatingRemainder(dividingBy: period)) / period
        let index = min(Int(progress * Double(projected.count - 1)), projected.count - 1)

        guard let dot = projected[index] else { return }
        // The same light the night side uses for a city, so a travelling dot
        // reads as something lit rather than a sticker on the glass.
        GlowDot.draw(in: &context, at: dot, radius: Layout.dotGlowRadius, colour: tint)
    }

    /// Arcs ride above the surface, so a point stays visible a little past the
    /// limb rather than vanishing the moment the ground beneath it does.
    private func project(_ point: SIMD3<Float>, in frame: GlobeFrame) -> CGPoint? {
        let rotated = GlobeProjection.rotate(point, by: camera)
        guard Double(rotated.z) > Layout.behindLimb else { return nil }
        return CGPoint(
            x: frame.centre.x + Double(rotated.x) * frame.radius,
            y: frame.centre.y - Double(rotated.y) * frame.radius
        )
    }

    /// One colour for every arc and every light on it, from the look.
    private var tint: Color {
        theme.globe.arcTint.color
    }
}

extension GlobeArcsOverlay {
    private enum Layout {
        static let lineOpacity = 0.55
        static let lineWidth: Double = 1.1
        static let dash: [CGFloat] = [2, 5]
        /// The halo, not the core: the light is bright in the middle and
        /// fades well before this.
        static let dotGlowRadius: Double = 7
        /// Radians of arc a dot covers each second.
        static let dotSpeed = 0.22
        /// Arcs are lifted, so they may show slightly beyond the horizon.
        static let behindLimb = -0.02
    }
}
