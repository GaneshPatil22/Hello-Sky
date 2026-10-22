import Foundation
import Testing

@testable import SkyCore

@Suite("Local time")
struct LocalTimeTests {
    private func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    private func zone(_ identifier: String) -> TimeZone {
        TimeZone(identifier: identifier)!
    }

    @Test("Reads a half-hour offset correctly")
    func halfHourZone() {
        let hour = LocalTime.hour(at: date("2026-10-22T06:00:00Z"), in: zone("Asia/Kolkata"))
        #expect(abs(hour - 11.5) < 0.001, "India should be 11:30, got \(hour)")
    }

    @Test("Reads a 45-minute offset correctly")
    func fortyFiveMinuteZone() {
        let hour = LocalTime.hour(at: date("2026-10-22T06:00:00Z"), in: zone("Asia/Kathmandu"))
        #expect(abs(hour - 11.75) < 0.001, "Nepal should be 11:45, got \(hour)")
    }

    @Test("Wraps past midnight rather than exceeding 24")
    func wrapsAtMidnight() {
        let hour = LocalTime.hour(at: date("2026-10-22T20:00:00Z"), in: zone("Asia/Tokyo"))
        #expect(abs(hour - 5) < 0.001, "Tokyo should be 05:00 the next day, got \(hour)")
    }

    @Test("Follows a daylight-saving change in Britain")
    func britishSummerTime() {
        let before = LocalTime.offset(at: date("2026-03-29T00:00:00Z"), from: zone("UTC"), to: zone("Europe/London"))
        let after = LocalTime.offset(at: date("2026-03-29T02:00:00Z"), from: zone("UTC"), to: zone("Europe/London"))

        #expect(before == 0)
        #expect(after == 1)
    }

    @Test("Follows a daylight-saving change in America on its own date")
    func americanDaylightTimeEndsLater() {
        // Britain changed on 2026-03-29 and America on 2026-03-08, so for three
        // weeks the usual five-hour gap to New York is only four.
        let gap = LocalTime.offset(
            at: date("2026-03-15T12:00:00Z"),
            from: zone("Europe/London"),
            to: zone("America/New_York")
        )
        #expect(gap == -4, "expected a four-hour gap in the overlap window, got \(gap)")

        let settled = LocalTime.offset(
            at: date("2026-04-15T12:00:00Z"),
            from: zone("Europe/London"),
            to: zone("America/New_York")
        )
        #expect(settled == -5)
    }

    @Test("Reports the right day across the date line")
    func dateLine() {
        // No single moment shows both sides: when Auckland has rolled over,
        // Honolulu is fourteen hours behind it but still on the UTC date.
        let aucklandAhead = date("2026-10-22T11:00:00Z") // 00:00 on the 23rd there
        #expect(LocalTime.relativeDay(at: aucklandAhead, in: zone("Pacific/Auckland"), comparedTo: zone("UTC")) == .tomorrow)

        let honoluluBehind = date("2026-10-22T05:00:00Z") // 19:00 on the 21st there
        #expect(LocalTime.relativeDay(at: honoluluBehind, in: zone("Pacific/Honolulu"), comparedTo: zone("UTC")) == .yesterday)

        #expect(LocalTime.relativeDay(at: aucklandAhead, in: zone("UTC"), comparedTo: zone("UTC")) == .sameDay)
        #expect(LocalTime.relativeDay(at: aucklandAhead, in: zone("Pacific/Auckland"), comparedTo: zone("Pacific/Honolulu")) == .tomorrow)
    }

    @Test("Handles a leap day without drifting")
    func leapDay() {
        let leapDay = date("2028-02-29T12:00:00Z")
        let hour = LocalTime.hour(at: leapDay, in: zone("UTC"))
        #expect(hour == 12)

        let dayAfter = date("2028-03-01T12:00:00Z")
        #expect(dayAfter.timeIntervalSince(leapDay) == 86_400)
        #expect(LocalTime.relativeDay(at: leapDay, in: zone("UTC"), comparedTo: zone("UTC")) == .sameDay)
    }

    @Test("Every fixture's time zone yields an hour inside the day")
    func allFixturesReadable() {
        for person in PersonFixtures.all {
            guard let timeZone = person.place.timeZone else {
                Issue.record("\(person.name) has no time zone")
                continue
            }
            let hour = LocalTime.hour(at: .now, in: timeZone)
            #expect(hour >= 0 && hour < 24, "\(person.name) read \(hour)")
        }
    }
}
