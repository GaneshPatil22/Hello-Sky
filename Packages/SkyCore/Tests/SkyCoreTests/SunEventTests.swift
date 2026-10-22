import Foundation
import Testing

@testable import SkyCore

@Suite("Sunrise and sunset")
struct SunEventTests {
    @Test("Matches astral within two minutes for every reference row")
    func matchesAstral() {
        for row in SolarReference.all {
            let day = Sun.solarDay(around: row.noon, at: row.coordinate)

            guard let sunset = day.next, sunset.kind == .sunset,
                  let sunrise = day.previous, sunrise.kind == .sunrise else {
                Issue.record("\(row.label) did not produce a sunrise then a sunset")
                continue
            }
            let sunriseError = abs(sunrise.date.timeIntervalSince(row.sunrise))
            let sunsetError = abs(sunset.date.timeIntervalSince(row.sunset))

            #expect(sunriseError < SolarReference.tolerance,
                    "\(row.label) sunrise off by \(Int(sunriseError))s")
            #expect(sunsetError < SolarReference.tolerance,
                    "\(row.label) sunset off by \(Int(sunsetError))s")
        }
    }

    @Test("Reports midnight sun above the Arctic circle in June")
    func midnightSun() {
        let longyearbyen = Coordinate(latitude: 78.22, longitude: 15.65)
        let midJune = Date(timeIntervalSince1970: 1_781_000_000) // 2026-06-15T...Z
        let day = Sun.solarDay(around: midJune, at: longyearbyen)

        #expect(day.isDaylight)
        #expect(day.next == nil)
        #expect(day.polarCondition == .midnightSun)
    }

    @Test("Reports polar night above the Arctic circle in December")
    func polarNight() {
        let longyearbyen = Coordinate(latitude: 78.22, longitude: 15.65)
        let midDecember = Date(timeIntervalSince1970: 1_797_000_000) // 2026-12-19T...Z
        let day = Sun.solarDay(around: midDecember, at: longyearbyen)

        #expect(!day.isDaylight)
        #expect(day.next == nil)
        #expect(day.polarCondition == .polarNight)
    }

    @Test("A normal day has no polar condition")
    func noPolarConditionElsewhere() {
        let london = Coordinate(latitude: 51.51, longitude: -0.13)
        let day = Sun.solarDay(around: .now, at: london)
        #expect(day.polarCondition == nil)
        #expect(day.next != nil)
        #expect(day.previous != nil)
    }

    @Test("The next event is always after now, and the previous always before")
    func eventsStraddleTheMoment() {
        let moment = Date(timeIntervalSince1970: 1_792_000_000)
        for person in PersonFixtures.all {
            let day = Sun.solarDay(around: moment, at: person.place.coordinate)
            if let next = day.next { #expect(next.date > moment, "\(person.place.city)") }
            if let previous = day.previous { #expect(previous.date < moment, "\(person.place.city)") }
        }
    }

    @Test("Finding the next event is fast enough to call every second")
    func searchIsFastEnough() {
        let london = Coordinate(latitude: 51.51, longitude: -0.13)
        let iterations = 100
        let started = ContinuousClock.now
        for step in 0..<iterations {
            _ = Sun.solarDay(around: .now.addingTimeInterval(Double(step) * 3_600), at: london)
        }
        let each = (ContinuousClock.now - started) / iterations
        #expect(each < .milliseconds(20), "one search took \(each)")
    }
}
