import Foundation
import Testing

@testable import SkyCore

@Suite("Person fixtures")
struct PersonFixturesTests {
    @Test("Every fixture has a coordinate the system accepts")
    func coordinatesAreValid() {
        for person in PersonFixtures.all {
            #expect(person.place.coordinate.isValid, "\(person.name) has an out-of-range coordinate")
        }
    }

    @Test("Every fixture names a time zone the system knows")
    func timeZonesResolve() {
        for person in PersonFixtures.all {
            #expect(person.place.timeZone != nil, "\(person.name) names an unknown time zone")
        }
    }

    @Test("Every fixture has a sensible awake window")
    func awakeHoursAreValid() {
        for person in PersonFixtures.all {
            #expect(person.awakeHours.isValid, "\(person.name) has an invalid awake window")
        }
    }

    @Test("Identifiers are unique")
    func identifiersAreUnique() {
        let ids = PersonFixtures.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("The cast covers a half-hour offset and a near-polar latitude")
    func coversEdgeCases() {
        let halfHour = PersonFixtures.all.contains { person in
            guard let zone = person.place.timeZone else { return false }
            return zone.secondsFromGMT() % 3600 != 0
        }
        let nearPolar = PersonFixtures.all.contains { abs($0.place.coordinate.latitude) > 60 }
        #expect(halfHour)
        #expect(nearPolar)
    }
}
