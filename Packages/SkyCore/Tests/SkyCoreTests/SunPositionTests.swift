import Foundation
import Testing

@testable import SkyCore

@Suite("Sun position")
struct SunPositionTests {
    private func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    @Test("Declination reaches the obliquity at the solstices")
    func solsticeDeclination() {
        let june = Sun.subsolarPoint(at: date("2026-06-21T12:00:00Z")).declination
        let december = Sun.subsolarPoint(at: date("2026-12-21T12:00:00Z")).declination

        #expect(abs(june - 23.44) < 0.2, "June declination was \(june)")
        #expect(abs(december + 23.44) < 0.2, "December declination was \(december)")
    }

    @Test("Declination crosses zero at the equinoxes")
    func equinoxDeclination() {
        for moment in ["2026-03-20T14:46:00Z", "2026-09-23T00:05:00Z"] {
            let declination = Sun.subsolarPoint(at: date(moment)).declination
            #expect(abs(declination) < 0.3, "\(moment) gave \(declination)")
        }
    }

    @Test("The subsolar point tracks west at fifteen degrees an hour")
    func subsolarMovesWest() {
        let start = date("2026-06-21T00:00:00Z")
        let first = Sun.subsolarPoint(at: start).longitude
        let later = Sun.subsolarPoint(at: start.addingTimeInterval(3_600)).longitude
        let travelled = Angle.signedDegrees(first - later)

        #expect(abs(travelled - 15) < 0.1, "moved \(travelled)° in an hour")
    }

    @Test("At solar noon the sun stands on the side the declination puts it")
    func azimuthAtNoon() {
        // Not simply "south in the north": a place inside the tropics sees the
        // noon sun to the north whenever the declination is above its latitude,
        // and Rio at the December solstice sits just north of the subsolar point.
        for row in SolarReference.all {
            let declination = Sun.subsolarPoint(at: row.noon).declination
            let separation = row.latitude - declination
            guard abs(separation) > 5 else { continue } // skip near-overhead cases

            let azimuth = Sun.position(at: row.noon, from: row.coordinate).azimuth
            if separation > 0 {
                #expect(abs(azimuth - 180) < 1, "\(row.label) faced \(azimuth)°, expected south")
            } else {
                let fromNorth = min(azimuth, 360 - azimuth)
                #expect(fromNorth < 1, "\(row.label) faced \(azimuth)°, expected north")
            }
        }
    }

    @Test("Azimuth runs east in the morning and west in the afternoon")
    func azimuthSweepsEastToWest() {
        let london = Coordinate(latitude: 51.51, longitude: -0.13)
        let morning = Sun.position(at: date("2026-06-21T07:00:00Z"), from: london).azimuth
        let afternoon = Sun.position(at: date("2026-06-21T17:00:00Z"), from: london).azimuth

        #expect(morning > 60 && morning < 150, "morning azimuth \(morning)")
        #expect(afternoon > 210 && afternoon < 300, "afternoon azimuth \(afternoon)")
    }

    @Test("Elevation peaks at solar noon")
    func elevationPeaksAtNoon() {
        for row in SolarReference.all.prefix(12) {
            let atNoon = Sun.position(at: row.noon, from: row.coordinate).elevation
            for shift in [-3.0, -1.0, 1.0, 3.0] {
                let nearby = Sun.position(
                    at: row.noon.addingTimeInterval(shift * 3_600),
                    from: row.coordinate
                ).elevation
                #expect(nearby <= atNoon + 0.01, "\(row.label) was higher \(shift)h from noon")
            }
        }
    }

    @Test("The hour angle is zero at solar noon")
    func hourAngleAtNoon() {
        for row in SolarReference.all {
            let hourAngle = Sun.position(at: row.noon, from: row.coordinate).hourAngle
            #expect(abs(hourAngle) < 0.5, "\(row.label) had hour angle \(hourAngle)")
        }
    }

    @Test("Phases follow the sun down through the thresholds")
    func phaseThresholds() {
        #expect(SolarPhase(sunElevation: 45) == .day)
        #expect(SolarPhase(sunElevation: 10) == .day)
        #expect(SolarPhase(sunElevation: 5) == .goldenHour)
        #expect(SolarPhase(sunElevation: 0) == .goldenHour)
        #expect(SolarPhase(sunElevation: -3) == .blueHour)
        #expect(SolarPhase(sunElevation: -6) == .blueHour)
        #expect(SolarPhase(sunElevation: -10) == .night)
    }
}
