import Foundation
import SkyCore
import Testing

@testable import SkyUI

@Suite("Sky snapshot")
struct SkySnapshotTests {
    private let london = PersonFixtures.you.place
    private func date(_ iso: String) -> Date { try! Date(iso, strategy: .iso8601) }

    @Test("The same inputs always give the same snapshot")
    func isPure() {
        let moment = date("2026-06-21T12:00:00Z")
        let weather = SkyWeather.Samples.partlyCloudy(at: moment)
        let first = SkySnapshot(place: london, date: moment, weather: weather, theme: .realistic)
        let second = SkySnapshot(place: london, date: moment, weather: weather, theme: .realistic)

        #expect(first == second)
    }

    @Test("Changing any one input changes the snapshot")
    func everyInputMatters() {
        let moment = date("2026-06-21T12:00:00Z")
        let weather = SkyWeather.Samples.clear(at: moment)
        let base = SkySnapshot(place: london, date: moment, weather: weather, theme: .realistic)

        #expect(base != SkySnapshot(place: PersonFixtures.kenji.place, date: moment,
                                    weather: weather, theme: .realistic))
        #expect(base != SkySnapshot(place: london, date: moment.addingTimeInterval(6 * 3_600),
                                    weather: weather, theme: .realistic))
        #expect(base != SkySnapshot(place: london, date: moment,
                                    weather: SkyWeather.Samples.raining(at: moment), theme: .realistic))
        #expect(base != SkySnapshot(place: london, date: moment, weather: weather, theme: .ink))
    }

    @Test("Each place gets its own seed, so no two cities share a sky")
    func seedsDifferByPlace() {
        let moment = date("2026-06-21T12:00:00Z")
        let seeds = SkyGalleryCase.places.map {
            SkySnapshot(place: $0, date: moment,
                        weather: SkyWeather.Samples.clear(at: moment), theme: .realistic).seed
        }
        #expect(Set(seeds).count == seeds.count)
    }

    @Test("Stars come out after dark and are gone by day")
    func starsFollowTheSun() {
        #expect(SkySnapshot.starVisibility(sunElevation: 30, cloud: 0) == 0)
        #expect(SkySnapshot.starVisibility(sunElevation: -6, cloud: 0) == 0)
        #expect(SkySnapshot.starVisibility(sunElevation: -18, cloud: 0) == 1)
        #expect(SkySnapshot.starVisibility(sunElevation: -40, cloud: 0) == 1)

        let halfDark = SkySnapshot.starVisibility(sunElevation: -12, cloud: 0)
        #expect(halfDark > 0.4 && halfDark < 0.6, "got \(halfDark)")
    }

    @Test("Cloud hides the stars")
    func cloudHidesStars() {
        let clear = SkySnapshot.starVisibility(sunElevation: -20, cloud: 0)
        let overcast = SkySnapshot.starVisibility(sunElevation: -20, cloud: 1)
        #expect(clear == 1)
        #expect(overcast < 0.1, "got \(overcast)")
    }

    @Test("The glow is strongest at the horizon and gone below it")
    func glowPeaksAtTheHorizon() {
        #expect(SkySnapshot.sunGlow(sunElevation: -10, cloud: 0) == 0)
        let atHorizon = SkySnapshot.sunGlow(sunElevation: 0, cloud: 0)
        let high = SkySnapshot.sunGlow(sunElevation: 25, cloud: 0)
        #expect(atHorizon > high, "horizon \(atHorizon) should beat high \(high)")
        #expect(high == 0)
    }

    @Test("Cloud dims the glow without removing it")
    func cloudDimsGlow() {
        let clear = SkySnapshot.sunGlow(sunElevation: 0, cloud: 0)
        let overcast = SkySnapshot.sunGlow(sunElevation: 0, cloud: 1)
        #expect(overcast < clear)
        #expect(overcast > 0, "overcast skies still brighten where the sun is")
    }

    @Test("A new moon is not drawn")
    func newMoonIsSkipped() {
        let newMoonNight = date("2026-01-18T23:00:00Z")
        let snapshot = SkySnapshot(place: london, date: newMoonNight,
                                   weather: SkyWeather.Samples.clear(at: newMoonNight), theme: .realistic)
        if snapshot.moonPhase.illumination <= SkySnapshot.Thresholds.faintestVisibleMoon {
            #expect(!snapshot.isMoonVisible)
        }
    }

    @Test("Every gallery case produces a usable snapshot")
    func galleryCasesAreSound() {
        for moment in SkyGalleryCase.snapshotCases {
            for theme in ThemeRegistry.standard.themes {
                let snapshot = SkySnapshot(place: moment.place, date: moment.date,
                                           weather: moment.weather, theme: theme)
                #expect(snapshot.starVisibility >= 0 && snapshot.starVisibility <= 1, "\(moment.label)")
                #expect(snapshot.sunGlow >= 0 && snapshot.sunGlow <= 1, "\(moment.label)")
                #expect(snapshot.rain >= 0 && snapshot.rain <= 1, "\(moment.label)")
            }
        }
    }
}

@Suite("Sky placement and accent")
struct SkyPlacementTests {
    private let london = PersonFixtures.you.place
    private let nairobi = PersonFixtures.amara.place
    private func date(_ iso: String) -> Date { try! Date(iso, strategy: .iso8601) }

    @Test("Noon puts the sun in the middle, morning left, evening right")
    func hourAngleSweeps() {
        #expect(abs(SkySnapshot.across(hourAngle: 0) - 0.5) < 0.001)
        #expect(SkySnapshot.across(hourAngle: -90) < 0.3)
        #expect(SkySnapshot.across(hourAngle: 90) > 0.7)
    }

    @Test("Placement stays inside the frame at every hour angle")
    func placementIsBounded() {
        for angle in stride(from: -180.0, through: 180.0, by: 10.0) {
            let across = SkySnapshot.across(hourAngle: angle)
            #expect(across >= 0 && across <= 1, "\(angle) gave \(across)")
        }
    }

    @Test("The sun traces an arc near the equator, not a vertical line")
    func equatorialSunArcs() {
        // Nairobi is the case azimuth got wrong: it barely moves all morning
        // and then swings through half a turn within minutes of noon.
        var positions: [Double] = []
        for hour in stride(from: 3.0, through: 15.0, by: 1.0) {
            let moment = date("2026-10-23T00:00:00Z").addingTimeInterval(hour * 3_600)
            let snapshot = SkySnapshot(place: nairobi, date: moment,
                                       weather: SkyWeather.Samples.clear(at: moment), theme: .realistic)
            positions.append(SkySnapshot.across(hourAngle: snapshot.sun.hourAngle))
        }
        // Strictly left to right, with no jump bigger than a sensible step.
        for (earlier, later) in zip(positions, positions.dropFirst()) {
            #expect(later > earlier, "the sun went backwards")
            #expect(later - earlier < 0.1, "the sun jumped from \(earlier) to \(later)")
        }
        #expect(positions.last! - positions.first! > 0.3, "the sun barely moved across")
    }

    @Test("The accent follows the sky instead of jumping between two colours")
    func accentIsGradual() {
        var accents: [SkyColor] = []
        for hour in stride(from: 0.0, through: 23.0, by: 1.0) {
            let moment = date("2026-10-23T00:00:00Z").addingTimeInterval(hour * 3_600)
            let snapshot = SkySnapshot(place: london, date: moment,
                                       weather: SkyWeather.Samples.clear(at: moment), theme: .realistic)
            accents.append(snapshot.accent)
        }
        #expect(Set(accents).count > 12, "the accent only took \(Set(accents).count) values across a day")

        for (earlier, later) in zip(accents, accents.dropFirst()) {
            let step = max(abs(later.red - earlier.red),
                           abs(later.green - earlier.green),
                           abs(later.blue - earlier.blue))
            #expect(step < 0.2, "the accent jumped by \(step) in an hour")
        }
    }

    @Test("A night sky gets a warm accent, a day sky a pale one")
    func accentWarmsAtNight() {
        func accent(atHour hour: Double) -> SkyColor {
            let moment = date("2026-06-21T00:00:00Z").addingTimeInterval(hour * 3_600)
            return SkySnapshot(place: london, date: moment,
                               weather: SkyWeather.Samples.clear(at: moment), theme: .realistic).accent
        }
        let night = accent(atHour: 1)
        let midday = accent(atHour: 12)

        #expect(night.red > night.blue, "night should lean warm")
        #expect(midday.red + midday.green + midday.blue > night.red + night.green + night.blue,
                "midday should be the brighter of the two")
    }
}

@Suite("Sky vertical placement")
struct SkyVerticalPlacementTests {
    private let height = 600.0

    @Test("The horizon sits where the hills are")
    func horizonPlacement() {
        let atHorizon = SkySnapshot.verticalPosition(elevation: 0, in: height)
        #expect(abs(atHorizon - height * 0.78) < 0.001)
    }

    @Test("Overhead stops short of the top edge")
    func overheadStaysInFrame() {
        // The bug this guards: Nairobi's midday sun is nearly overhead, and a
        // mapping that saturates at the top draws it half off the screen.
        for elevation in [70.0, 85.0, 90.0] {
            let y = SkySnapshot.verticalPosition(elevation: elevation, in: height)
            #expect(y > height * 0.1, "elevation \(elevation) reached \(y)")
        }
    }

    @Test("Rising moves it up, never down")
    func risingMovesUp() {
        var previous = SkySnapshot.verticalPosition(elevation: 0, in: height)
        for elevation in stride(from: 5.0, through: 90.0, by: 5.0) {
            let y = SkySnapshot.verticalPosition(elevation: elevation, in: height)
            #expect(y < previous, "elevation \(elevation) did not rise")
            previous = y
        }
    }

    @Test("Below the horizon it does not climb back up")
    func belowHorizonIsClamped() {
        let below = SkySnapshot.verticalPosition(elevation: -20, in: height)
        #expect(abs(below - height * 0.78) < 0.001)
    }
}
