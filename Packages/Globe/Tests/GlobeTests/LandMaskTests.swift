import Foundation
import SkyCore
import Testing
import simd

@testable import Globe

@Suite("Land mask")
struct LandMaskTests {
    @Test("Loads at the expected size")
    func loads() {
        #expect(LandMask.bits.count == LandMask.width * LandMask.height / 8)
        #expect(LandMask.bits.count == 32_400)
    }

    @Test("Knows the continents")
    func findsLand() {
        let onLand: [(String, Double, Double)] = [
            ("London", 51.5, -0.1), ("Paris", 48.9, 2.3), ("Sahara", 23.0, 12.0),
            ("Siberia", 62.0, 100.0), ("Kansas", 38.5, -98.0), ("Amazon", -5.0, -60.0),
            ("Outback", -25.0, 133.0), ("Antarctica", -80.0, 0.0),
        ]
        for (name, latitude, longitude) in onLand {
            #expect(LandMask.isLand(latitude: latitude, longitude: longitude), "\(name) should be land")
        }
    }

    @Test("Knows the oceans")
    func findsSea() {
        let atSea: [(String, Double, Double)] = [
            ("mid Pacific", 0.0, -150.0), ("mid Atlantic", 30.0, -40.0),
            ("Indian Ocean", -20.0, 80.0), ("Southern Ocean", -55.0, 100.0),
            ("North Pacific", 40.0, -170.0),
        ]
        for (name, latitude, longitude) in atSea {
            #expect(!LandMask.isLand(latitude: latitude, longitude: longitude), "\(name) should be sea")
        }
    }

    @Test("Every city someone can follow is on land")
    func fixtureCitiesAreOnLand() {
        // A coastal city can sit a cell offshore at half-degree resolution, so
        // this allows the immediate neighbourhood rather than the exact cell.
        for person in PersonFixtures.all {
            let coordinate = person.place.coordinate
            let nearby = (-1...1).flatMap { dy in
                (-1...1).map { dx in
                    LandMask.isLand(
                        latitude: coordinate.latitude + Double(dy) * 0.5,
                        longitude: coordinate.longitude + Double(dx) * 0.5
                    )
                }
            }
            #expect(nearby.contains(true), "\(person.place.city) is nowhere near land")
        }
    }

    @Test("Coordinates outside the usual range do not read past the end")
    func clampsOutOfRange() {
        _ = LandMask.isLand(latitude: 95, longitude: 200)
        _ = LandMask.isLand(latitude: -95, longitude: -200)
        #expect(Bool(true), "reading out of range must not trap")
    }

    @Test("Land covers about a third of the grid")
    func landFraction() {
        var cells = 0
        for row in stride(from: -89.5, through: 89.5, by: 1.0) {
            for column in stride(from: -179.5, through: 179.5, by: 1.0)
            where LandMask.isLand(latitude: row, longitude: column) {
                cells += 1
            }
        }
        let fraction = Double(cells) / (180.0 * 360.0)
        // Higher than the true 29% because equal-angle cells over-weight the
        // poles, and Antarctica is large there.
        #expect(fraction > 0.25 && fraction < 0.40, "got \(fraction)")
    }
}

@Suite("Globe dot field")
struct GlobeDotFieldTests {
    @Test("Every dot sits on the sphere")
    func dotsAreOnTheSphere() {
        for point in GlobeDotField.points.prefix(500) {
            #expect(abs(simd_length(point) - 1) < 0.0001)
        }
    }

    @Test("Every dot sits on land")
    func dotsAreOnLand() {
        for point in GlobeDotField.points.prefix(500) {
            let coordinate = GlobeGeometry.coordinate(for: point)
            #expect(LandMask.isLand(coordinate), "a dot landed at sea")
        }
    }

    @Test("There are enough dots to read as continents")
    func enoughDots() {
        #expect(GlobeDotField.points.count > 3_000, "only \(GlobeDotField.points.count)")
    }

    @Test("Lower tiers thin the dots rather than cropping them")
    func qualityThins() {
        #expect(GlobeDotField.count(for: .high) > GlobeDotField.count(for: .medium))
        #expect(GlobeDotField.count(for: .medium) > GlobeDotField.count(for: .low))
        #expect(GlobeDotField.count(for: .low) > 0)
    }
}
