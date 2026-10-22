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
