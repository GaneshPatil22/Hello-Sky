import Foundation
import SkyCore
import SwiftUI
import Testing
import simd

@testable import Globe

/// Checks the drawn night half against the real one.
///
/// The user-visible bug this exists to stop: if the shadow is built from
/// different maths than the continents, turning the globe slides the night over
/// the wrong countries — India in darkness at 11:50 PM one moment and in
/// daylight the next, without time having moved at all.
@MainActor
@Suite("Globe night side")
struct GlobeNightSideTests {
    private let size = CGSize(width: 400, height: 400)

    private func check(camera: GlobeCamera, date: Date) -> (checked: Int, wrong: Int) {
        let frame = GlobeFrame(camera: camera, date: date, size: size)
        let region = GlobeNightSide.nightRegion(frame: frame)

        var checked = 0
        var wrong = 0
        for row in stride(from: 0.0, to: size.height, by: 7) {
            for column in stride(from: 0.0, to: size.width, by: 7) {
                let screen = CGPoint(x: column, y: row)
                guard let surface = GlobeProjection.surfacePoint(
                    at: screen, camera: camera, centre: frame.centre, radius: frame.radius
                ) else { continue }

                let light = frame.light(at: surface)
                // Points within a whisker of the terminator may fall either
                // way; only clear day and clear night are judged.
                guard abs(light) > 0.06 else { continue }

                checked += 1
                if region.contains(screen) != (light < 0) { wrong += 1 }
            }
        }
        return (checked, wrong)
    }

    @Test("The shadow covers exactly the half that is in darkness")
    func shadowMatchesTheLight() {
        let date = try! Date("2026-10-22T18:20:00Z", strategy: .iso8601)
        for longitude in stride(from: 0.0, to: 360.0, by: 20.0) {
            for latitude in [-40.0, 0.0, 35.0] {
                let camera = GlobeCamera(longitude: longitude, latitude: latitude)
                let (checked, wrong) = check(camera: camera, date: date)
                #expect(checked > 100, "not enough samples at \(longitude), \(latitude)")
                #expect(wrong == 0, "\(wrong) of \(checked) wrong at longitude \(longitude), latitude \(latitude)")
            }
        }
    }

    @Test("It holds through a whole day, not just one moment")
    func shadowMatchesAcrossTheDay() {
        let start = try! Date("2026-06-21T00:00:00Z", strategy: .iso8601)
        for hour in stride(from: 0, to: 24, by: 3) {
            let date = start.addingTimeInterval(Double(hour) * 3_600)
            let (checked, wrong) = check(camera: GlobeCamera(longitude: 40, latitude: 20), date: date)
            #expect(wrong == 0, "\(wrong) of \(checked) wrong at \(hour)h")
        }
    }

    @Test("A city's daylight does not change when the globe is turned")
    func turningDoesNotChangeTheTime() {
        let date = try! Date("2026-10-22T18:20:00Z", strategy: .iso8601)
        // India at 11:50 PM: firmly in night, and it must stay there.
        let delhi = GlobeGeometry.vector(for: Coordinate(latitude: 28.6, longitude: 77.2))

        var readings: [Bool] = []
        for longitude in stride(from: 0.0, to: 360.0, by: 15.0) {
            let frame = GlobeFrame(camera: GlobeCamera(longitude: longitude), date: date, size: size)
            readings.append(frame.light(at: delhi) < 0)
        }
        #expect(Set(readings).count == 1, "turning the globe changed whether Delhi is in daylight")
        #expect(readings.first == true, "Delhi should be in night at 18:20 UTC")
    }
}
