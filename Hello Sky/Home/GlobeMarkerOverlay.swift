import Globe
import SkyCore
import SwiftUI

/// The people, drawn over the globe where their cities have turned to.
///
/// Laid over the scene rather than placed in it, so each marker is a real
/// button with a label VoiceOver can read.
struct GlobeMarkerOverlay: View {
    let people: [Person]
    let camera: GlobeCamera
    let date: Date
    /// The frame's instant, used only for the pulsing rings.
    let now: Date
    let selected: Person?
    let onSelect: (Person) -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                arcs(in: proxy.size)
                ForEach(people) { person in
                    marker(for: person, in: proxy.size)
                }
            }
        }
    }

    @ViewBuilder
    private func marker(for person: Person, in size: CGSize) -> some View {
        if let point = GlobeProjection.screenPoint(for: person.place.coordinate, camera: camera, size: size) {
            let visibility = GlobeProjection.visibility(for: person.place.coordinate, camera: camera)
            Button {
                onSelect(person)
            } label: {
                GlobeMarker(person: person, date: date, isSelected: selected?.id == person.id, now: now)
            }
            .buttonStyle(.plain)
            .position(point)
            .opacity(visibility)
            // A marker edge-on is still technically hittable; it should not be.
            .allowsHitTesting(visibility > Layout.tappableAbove)
        }
    }

    /// Lines from you to everyone else, following the curve of the Earth.
    @ViewBuilder
    private func arcs(in size: CGSize) -> some View {
        if let you = people.first {
            ForEach(people.dropFirst()) { person in
                ArcShape(
                    points: GlobeProjection.arc(
                        from: you.place.coordinate,
                        to: person.place.coordinate,
                        camera: camera,
                        size: size
                    )
                )
                .stroke(
                    .white.opacity(selected?.id == person.id ? Layout.arcSelected : Layout.arcOpacity),
                    style: StrokeStyle(lineWidth: Layout.arcWidth, lineCap: .round)
                )
            }
            .allowsHitTesting(false)
        }
    }
}

extension GlobeMarkerOverlay {
    private enum Layout {
        static let tappableAbove = 0.35
        static let arcOpacity = 0.18
        static let arcSelected = 0.5
        static let arcWidth: Double = 1.2
    }
}
