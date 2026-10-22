import Foundation
import Testing

@testable import SkyCore

@Suite("Call status")
struct CallStatusTests {
    private let awake = AwakeHours(start: 8, end: 23)

    @Test("Mid-day is a good time")
    func middayIsGood() {
        #expect(CallStatus.status(localHour: 14, awakeHours: awake) == .good)
    }

    @Test("The first and last half hour awake are only a maybe")
    func edgesOfTheWakingWindow() {
        #expect(CallStatus.status(localHour: 8.2, awakeHours: awake) == .maybe)
        #expect(CallStatus.status(localHour: 22.8, awakeHours: awake) == .maybe)
        #expect(CallStatus.status(localHour: 8.6, awakeHours: awake) == .good)
        #expect(CallStatus.status(localHour: 22.4, awakeHours: awake) == .good)
    }

    @Test("An hour either side of the window is still a maybe")
    func justOutsideIsMaybe() {
        #expect(CallStatus.status(localHour: 7.2, awakeHours: awake) == .maybe)
        #expect(CallStatus.status(localHour: 23.5, awakeHours: awake) == .maybe)
    }

    @Test("The middle of the night is sleeping")
    func nightIsSleeping() {
        #expect(CallStatus.status(localHour: 3, awakeHours: awake) == .sleeping)
        #expect(CallStatus.status(localHour: 6.5, awakeHours: awake) == .sleeping)
    }

    @Test("A person in an unknown time zone reads as sleeping, never as a good time")
    func unknownTimeZoneIsSafe() {
        let broken = Person(
            id: "broken",
            name: "Nobody",
            avatar: .emoji("❓"),
            place: Place(
                id: "nowhere",
                city: "Nowhere",
                coordinate: Coordinate(latitude: 0, longitude: 0),
                timeZoneIdentifier: "Not/AZone"
            ),
            awakeHours: .default
        )
        #expect(CallStatus.status(for: broken, at: .now) == .sleeping)
    }

    @Test("Every fixture reads a status at any hour of the day")
    func fixturesAlwaysResolve() {
        let start = Date(timeIntervalSince1970: 1_792_000_000)
        for person in PersonFixtures.all {
            for hour in 0..<24 {
                let moment = start.addingTimeInterval(Double(hour) * 3_600)
                let status = CallStatus.status(for: person, at: moment)
                #expect(CallStatus.allCases.contains(status))
            }
        }
    }
}
