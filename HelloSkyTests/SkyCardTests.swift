import Foundation
import SkyCore
import SkyUI
import Testing

@testable import Hello_Sky

/// The share card is rendered rather than laid out on screen, so the only way
/// to know it works is to render one.
@MainActor
@Suite("Sky card", .serialized)
struct SkyCardTests {
    private let date = try! Date("2026-10-22T18:00:00Z", strategy: .iso8601)

    @Test("Renders a card at the size it claims")
    func rendersAtTheRightSize() {
        let image = SkyCard.image(
            person: PersonFixtures.kenji,
            weather: SkyWeather.Samples.partlyCloudy(at: date),
            date: date,
            theme: .realistic
        )
        let card = try! #require(image)
        #expect(card.size.width == SkyCardView.size.width)
        #expect(card.size.height == SkyCardView.size.height)
        #expect(card.scale == 3, "a card posted anywhere should be sharp")
    }

    @Test("Renders for every person and every look")
    func rendersEverything() {
        for person in PersonFixtures.all.prefix(4) {
            for theme in ThemeRegistry.standard.themes {
                let image = SkyCard.image(
                    person: person,
                    weather: SkyWeather.Samples.clear(at: date),
                    date: date,
                    theme: theme
                )
                #expect(image != nil, "\(person.name) in \(theme.id) produced nothing")
            }
        }
    }

    @Test("Names the card after whose sky it is")
    func titlesTheCard() {
        #expect(SkyCard.title(for: PersonFixtures.kenji) == "Kenji's sky")
    }

    @Test("Exports PNG data a share sheet can carry")
    func exportsPNG() async throws {
        let transfer = SkyCardTransfer(
            person: PersonFixtures.kenji,
            weather: SkyWeather.Samples.raining(at: date),
            date: date,
            theme: .realistic,
            locale: Locale(identifier: "en_GB")
        )
        let data = try await transfer.exported()
        #expect(data.count > 1_000, "only \(data.count) bytes, which is not an image")
        // PNG files start with a fixed eight-byte signature.
        #expect(Array(data.prefix(4)) == [0x89, 0x50, 0x4E, 0x47])
    }
}
