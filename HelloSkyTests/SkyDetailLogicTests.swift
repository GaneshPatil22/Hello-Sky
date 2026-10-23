import Foundation
import SkyCore
import Testing

@testable import Hello_Sky

@MainActor
@Suite("Sky detail wording")
struct SkyDetailLogicTests {
    private func zone(_ identifier: String) -> TimeZone { TimeZone(identifier: identifier)! }
    private let date = try! Date("2026-10-23T12:00:00Z", strategy: .iso8601)

    @Test("Says how far ahead or behind somewhere is")
    func offsetPhrase() {
        let london = zone("Europe/London")
        #expect(SkyHeadline.offsetPhrase(from: london, to: zone("Asia/Tokyo"), at: date)
            == "8 hours ahead of you")
        #expect(SkyHeadline.offsetPhrase(from: london, to: zone("America/New_York"), at: date)
            == "5 hours behind you")
        #expect(SkyHeadline.offsetPhrase(from: london, to: london, at: date)
            == "the same time as you")
    }

    @Test("Handles a half-hour offset without rounding it away")
    func halfHourOffset() {
        let phrase = SkyHeadline.offsetPhrase(from: zone("Europe/London"), to: zone("Asia/Kolkata"), at: date)
        #expect(phrase.contains("4.5"), "got \(phrase)")
        #expect(phrase.hasSuffix("ahead of you"))
    }

    @Test("Says one hour, not one hours")
    func singularHour() {
        let phrase = SkyHeadline.offsetPhrase(from: zone("Europe/London"), to: zone("Europe/Paris"), at: date)
        #expect(phrase == "1 hour ahead of you", "got \(phrase)")
    }

    @Test("Counts down to the next sun event in hours and minutes")
    func countdown() {
        let now = Date(timeIntervalSince1970: 0)
        #expect(SunArcCard.until(now.addingTimeInterval(7 * 3_600 + 7 * 60), from: now) == "7 h 7 min")
        #expect(SunArcCard.until(now.addingTimeInterval(45 * 60), from: now) == "45 min")
        #expect(SunArcCard.until(now.addingTimeInterval(2 * 3_600), from: now) == "2 h")
        #expect(SunArcCard.until(now.addingTimeInterval(-60), from: now) == "0 min")
    }

    @Test("Finds the stretches someone is awake")
    func awakeRuns() {
        #expect(OverlapBars.runs(in: [false, true, true, false, true]) == [1..<3, 4..<5])
        #expect(OverlapBars.runs(in: [true, true]) == [0..<2])
        #expect(OverlapBars.runs(in: [false, false]).isEmpty)
        #expect(OverlapBars.runs(in: []).isEmpty)
    }

    @Test("The arc puts sunrise on the left, noon at the top and sunset on the right")
    func arcShape() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let sunrise = SunArcShape.point(at: 0, in: rect)
        let noon = SunArcShape.point(at: 0.5, in: rect)
        let sunset = SunArcShape.point(at: 1, in: rect)

        #expect(sunrise.x == 0)
        #expect(sunset.x == 100)
        #expect(abs(noon.y - rect.minY) < 0.001, "noon should reach the top")
        #expect(abs(sunrise.y - rect.maxY) < 0.001)
        #expect(abs(sunset.y - rect.maxY) < 0.001)
    }

    @Test("A reminder is named after whose sky it is")
    func reminderWording() {
        let kenji = PersonFixtures.kenji
        #expect(SunReminder.title(for: .sunset, person: kenji) == "Sunset at Kenji's")
        #expect(SunReminder.body(for: .sunrise, person: kenji).contains("Tokyo"))
    }

    @Test("One pending reminder per person and event, so tapping twice replaces it")
    func reminderIdentifiersAreStable() {
        let event = SolarEvent(kind: .sunset, date: date)
        let later = SolarEvent(kind: .sunset, date: date.addingTimeInterval(86_400))
        #expect(SunReminder.identifier(for: PersonFixtures.kenji, event: event)
            == SunReminder.identifier(for: PersonFixtures.kenji, event: later))
        #expect(SunReminder.identifier(for: PersonFixtures.kenji, event: event)
            != SunReminder.identifier(for: PersonFixtures.ava, event: event))
    }
}
