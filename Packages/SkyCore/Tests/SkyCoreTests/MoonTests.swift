import Foundation
import Testing

@testable import SkyCore

@Suite("Moon")
struct MoonTests {
    private func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    @Test("Illumination is lowest at new moon and highest at full")
    func illuminationEndpoints() {
        #expect(MoonPhase(fraction: 0, illumination: 0).illumination == 0)

        // The reference new moon the model is anchored to.
        let newMoon = Moon.phase(at: date("2000-01-06T14:24:00Z"))
        #expect(newMoon.illumination < 0.02, "illumination was \(newMoon.illumination)")

        let fullMoon = Moon.phase(at: date("2000-01-06T14:24:00Z")
            .addingTimeInterval(Moon.Series.synodicMonth / 2 * 86_400))
        #expect(fullMoon.illumination > 0.98, "illumination was \(fullMoon.illumination)")
    }

    @Test("The phase fraction stays within one cycle, forwards and backwards")
    func fractionStaysInRange() {
        for days in stride(from: -400.0, through: 400.0, by: 7.0) {
            let moment = Date.now.addingTimeInterval(days * 86_400)
            let phase = Moon.phase(at: moment)
            #expect(phase.fraction >= 0 && phase.fraction < 1, "fraction \(phase.fraction) at \(days) days")
            #expect(phase.illumination >= 0 && phase.illumination <= 1)
        }
    }

    @Test("Returns to the same phase after one synodic month")
    func repeatsEachMonth() {
        let start = Date.now
        let later = start.addingTimeInterval(Moon.Series.synodicMonth * 86_400)
        let difference = abs(Moon.phase(at: start).fraction - Moon.phase(at: later).fraction)
        #expect(difference < 0.001, "drifted by \(difference)")
    }

    @Test("Names run through the whole cycle in order")
    func namesCoverTheCycle() {
        var seen: [MoonPhase.Name] = []
        for step in 0..<64 {
            let fraction = Double(step) / 64
            let name = MoonPhase(fraction: fraction, illumination: 0).name
            if seen.last != name { seen.append(name) }
        }
        #expect(seen.first == .new)
        #expect(Set(seen).count == MoonPhase.Name.allCases.count, "saw \(seen)")
    }

    @Test("Waxing before full, waning after")
    func waxingAndWaning() {
        #expect(MoonPhase(fraction: 0.25, illumination: 0.5).isWaxing)
        #expect(!MoonPhase(fraction: 0.75, illumination: 0.5).isWaxing)
    }

    @Test("Position stays on the celestial sphere everywhere")
    func positionIsWellFormed() {
        for person in PersonFixtures.all {
            for hour in stride(from: 0.0, to: 48.0, by: 3.0) {
                let moment = Date.now.addingTimeInterval(hour * 3_600)
                let position = Moon.position(at: moment, from: person.place.coordinate)
                #expect(position.elevation >= -90 && position.elevation <= 90)
                #expect(position.azimuth >= 0 && position.azimuth < 360)
            }
        }
    }

    @Test("A full moon is up when the sun is down")
    func fullMoonOpposesTheSun() {
        let london = Coordinate(latitude: 51.51, longitude: -0.13)
        var checked = 0

        for day in 0..<60 {
            let midnight = date("2026-01-01T00:00:00Z").addingTimeInterval(Double(day) * 86_400)
            guard Moon.phase(at: midnight).illumination > 0.97 else { continue }
            checked += 1
            let moon = Moon.position(at: midnight, from: london)
            let sun = Sun.position(at: midnight, from: london)
            #expect(!sun.isDaylight)
            #expect(moon.elevation > 0, "full moon was below the horizon at local midnight")
        }
        #expect(checked > 0, "no full moon found in the window")
    }
}
