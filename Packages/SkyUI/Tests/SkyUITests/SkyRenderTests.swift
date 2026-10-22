import CoreGraphics
import Foundation
import SkyCore
import SwiftUI
import Testing

@testable import SkyUI

/// Renders the twelve fixed cases and checks what a rendered sky must satisfy.
///
/// These are not golden-image tests. The look is still being tuned — the colour
/// tables are placeholders — so stored baselines would be rewritten on every
/// adjustment and would stop being read. What matters now, and will keep
/// mattering after the colours settle, is that a sky is a *pure function*: the
/// same inputs render identical pixels every time, and different inputs do not
/// collide. Golden images belong here once the looks are signed off.
///
/// Serialized: `ImageRenderer` occasionally returns `nil` when several suites
/// render at once, which showed up as a comparison failing rather than as a
/// missing image. The rendering itself is stable — forty back-to-back pairs
/// differ by zero bytes — so the contention was the only cause.
@MainActor
@Suite("Sky rendering", .serialized)
struct SkyRenderTests {
    private static let size = CGSize(width: 120, height: 180)

    /// Renders a case, failing the test if no image comes back rather than
    /// letting a `nil` turn into a confusing inequality.
    private func pixels(
        _ moment: SkyGalleryCase,
        theme: Theme = .realistic,
        motion: Double = 0,
        _ location: SourceLocation = #_sourceLocation
    ) throws -> Data {
        try #require(render(moment, theme: theme, motion: motion), "no image rendered", sourceLocation: location)
    }

    private func render(_ moment: SkyGalleryCase, theme: Theme = .realistic, motion: Double = 0) -> Data? {
        let snapshot = SkySnapshot(place: moment.place, date: moment.date,
                                   weather: moment.weather, theme: theme)
        let renderer = ImageRenderer(content: SkyView(snapshot: snapshot, motion: motion)
            .frame(width: Self.size.width, height: Self.size.height))
        renderer.scale = 1
        guard let image = renderer.cgImage, let data = image.dataProvider?.data else { return nil }
        return Data(referencing: data)
    }

    @Test("All twelve fixed cases render")
    func everyCaseRenders() {
        #expect(SkyGalleryCase.snapshotCases.count == 12)
        for moment in SkyGalleryCase.snapshotCases {
            #expect(render(moment) != nil, "\(moment.label) produced no image")
        }
    }

    @Test("The same sky renders identically every time")
    func renderingIsDeterministic() throws {
        for moment in SkyGalleryCase.snapshotCases {
            let first = try pixels(moment)
            let second = try pixels(moment)
            #expect(first == second, "\(moment.label) rendered differently on a second pass")
        }
    }

    @Test("No two of the fixed cases render the same")
    func casesAreDistinct() throws {
        var seen: [Data: String] = [:]
        for moment in SkyGalleryCase.snapshotCases {
            let data = try pixels(moment)
            if let clash = seen[data] {
                Issue.record("\(moment.label) renders identically to \(clash)")
            }
            seen[data] = moment.label
        }
        #expect(seen.count == SkyGalleryCase.snapshotCases.count)
    }

    @Test("Each look renders its own sky")
    func looksDiffer() throws {
        let moment = SkyGalleryCase.snapshotCases[0]
        let rendered = try ThemeRegistry.standard.themes.map { try pixels(moment, theme: $0) }
        #expect(rendered.count == 3)
        #expect(Set(rendered).count == 3, "two looks render the same sky")
    }

    @Test("Weather changes what is drawn")
    func weatherChangesTheSky() throws {
        let base = SkyGalleryCase.snapshotCases[0]
        let rendered = try SkyWeather.Samples.all(at: base.date).map { weather in
            try pixels(SkyGalleryCase(place: base.place, date: base.date, weather: weather, label: ""))
        }
        #expect(Set(rendered).count == rendered.count, "two weather types render the same")
    }

    @Test("A still frame is what Reduce Motion gets, and it is stable")
    func stillFrameIsStable() throws {
        let moment = SkyGalleryCase.snapshotCases[1]
        #expect(try pixels(moment, motion: 0) == pixels(moment, motion: 0))
    }

    @Test("Motion actually moves something")
    func motionChangesTheFrame() throws {
        // A rainy sky, so there is certainly something in flight.
        let base = SkyGalleryCase.snapshotCases[0]
        let rainy = SkyGalleryCase(place: base.place, date: base.date,
                                   weather: SkyWeather.Samples.raining(at: base.date), label: "rain")
        #expect(try pixels(rainy, motion: 0) != pixels(rainy, motion: 3))
    }
}
