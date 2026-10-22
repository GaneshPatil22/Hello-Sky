import Foundation
import SkyCore
import Testing
import simd

@testable import Globe

@Suite("Globe geometry")
struct GlobeGeometryTests {
    private func date(_ iso: String) -> Date { try! Date(iso, strategy: .iso8601) }

    @Test("Poles and the prime meridian land where they should")
    func knownPoints() {
        let north = GlobeGeometry.vector(for: Coordinate(latitude: 90, longitude: 0))
        #expect(abs(north.y - 1) < 0.0001)

        let nullIsland = GlobeGeometry.vector(for: Coordinate(latitude: 0, longitude: 0))
        #expect(abs(nullIsland.z - 1) < 0.0001)

        let east = GlobeGeometry.vector(for: Coordinate(latitude: 0, longitude: 90))
        #expect(abs(east.x - 1) < 0.0001)
    }

    @Test("Every vector is on the unit sphere")
    func vectorsAreUnitLength() {
        for person in PersonFixtures.all {
            let length = simd_length(GlobeGeometry.vector(for: person.place.coordinate))
            #expect(abs(length - 1) < 0.0001, "\(person.place.city)")
        }
    }

    @Test("Coordinates survive a round trip through the sphere")
    func roundTrip() {
        for person in PersonFixtures.all {
            let original = person.place.coordinate
            let returned = GlobeGeometry.coordinate(for: GlobeGeometry.vector(for: original))
            #expect(abs(returned.latitude - original.latitude) < 0.001, "\(person.place.city) latitude")
            #expect(abs(returned.longitude - original.longitude) < 0.001, "\(person.place.city) longitude")
        }
    }

    @Test("The sun direction agrees with the subsolar point from SkyCore")
    func sunDirectionMatchesSkyCore() {
        for hour in stride(from: 0, through: 48, by: 3) {
            let moment = date("2026-06-21T00:00:00Z").addingTimeInterval(Double(hour) * 3_600)
            let subsolar = Sun.subsolarPoint(at: moment)
            let returned = GlobeGeometry.coordinate(for: GlobeGeometry.sunDirection(at: moment))

            #expect(abs(returned.latitude - subsolar.declination) < 0.01, "declination at \(hour)h")
            #expect(abs(returned.longitude - subsolar.longitude) < 0.01, "longitude at \(hour)h")
        }
    }

    @Test("The day/night line crosses a city exactly when its sun elevation is zero")
    func terminatorMatchesSunElevation() {
        for person in PersonFixtures.all {
            let place = person.place
            let day = Sun.solarDay(around: date("2026-06-21T12:00:00Z"), at: place.coordinate)
            guard let event = day.next ?? day.previous else { continue }

            // At a sunrise or sunset the point is on the terminator, so its
            // daylight value — the dot product the shader uses — is zero.
            let daylight = GlobeGeometry.daylight(at: place.coordinate, date: event.date)
            #expect(abs(daylight) < 0.02, "\(place.city) read \(daylight) at its \(event.kind)")
        }
    }

    @Test("The subsolar point is in full daylight and its antipode in full night")
    func daylightExtremes() {
        let moment = date("2026-03-20T12:00:00Z")
        let subsolar = Sun.subsolarPoint(at: moment).coordinate
        let antipode = Coordinate(
            latitude: -subsolar.latitude,
            longitude: subsolar.longitude > 0 ? subsolar.longitude - 180 : subsolar.longitude + 180
        )
        #expect(GlobeGeometry.daylight(at: subsolar, date: moment) > 0.999)
        #expect(GlobeGeometry.daylight(at: antipode, date: moment) < -0.999)
    }

    @Test("Daylight agrees with sun elevation everywhere, at the solstices and equinoxes")
    func daylightAgreesWithElevation() {
        let moments = ["2026-03-20T12:00:00Z", "2026-06-21T12:00:00Z",
                       "2026-09-22T12:00:00Z", "2026-12-21T00:00:00Z"]
        for iso in moments {
            let moment = date(iso)
            for person in PersonFixtures.all {
                let daylight = GlobeGeometry.daylight(at: person.place.coordinate, date: moment)
                let elevation = Sun.position(at: moment, from: person.place.coordinate).elevation
                #expect((daylight > 0) == (elevation > 0),
                        "\(person.place.city) at \(iso): daylight \(daylight), elevation \(elevation)")
            }
        }
    }
}
