import Foundation
import Testing

@testable import SkyData

@Suite("Open-Meteo provider")
struct OpenMeteoProviderTests {
    private func provider(_ fixture: String = "open-meteo-tokyo") -> OpenMeteoProvider {
        OpenMeteoProvider(loader: StubLoader(fixture: fixture))
    }

    @Test("Decodes a saved response into SkyWeather")
    func decodesSavedResponse() async throws {
        let weather = try await provider().weather(for: .tokyo, at: WeatherTestDates.insideFixture)

        #expect(weather.origin == .live)
        #expect(weather.temperatureCelsius != nil)
        #expect(weather.cloudCover.total >= 0 && weather.cloudCover.total <= 1)
        #expect(weather.cloudCover.low != nil)
    }

    @Test("Converts percentages to fractions")
    func convertsPercentages() async throws {
        let weather = try await provider().weather(for: .tokyo, at: WeatherTestDates.insideFixture)
        // Hour 10 of the fixture reports 70% total cloud.
        #expect(abs(weather.cloudCover.total - 0.70) < 0.001, "got \(weather.cloudCover.total)")
    }

    @Test("Scales precipitation into a rain intensity, capped at one")
    func scalesRain() async throws {
        let moderate = try await provider().weather(for: .tokyo, at: WeatherTestDates.rainyHour)
        let heavy = try await provider().weather(for: .tokyo, at: WeatherTestDates.heavyRainHour)

        #expect(moderate.rain > 0 && moderate.rain < 1, "got \(moderate.rain)")
        #expect(heavy.rain == 1, "7mm should saturate, got \(heavy.rain)")
    }

    @Test("Maps WMO codes to conditions")
    func mapsConditions() async throws {
        let fog = try await provider().weather(for: .tokyo, at: WeatherTestDates.foggyHour)
        let rain = try await provider().weather(for: .tokyo, at: WeatherTestDates.rainyHour)

        #expect(fog.condition == .fog)
        #expect(rain.condition == .rain)
        #expect(rain.condition.isPrecipitating)
        #expect(!fog.condition.isPrecipitating)
    }

    @Test("Works when the optional cloud layers are missing")
    func toleratesMissingLayers() async throws {
        let weather = try await provider("open-meteo-minimal")
            .weather(for: .tokyo, at: WeatherTestDates.insideFixture)

        #expect(weather.cloudCover.low == nil)
        #expect(weather.cloudCover.total > 0)
    }

    @Test("Reports when the response does not cover the hour asked for")
    func missingHour() async {
        await #expect(throws: OpenMeteoError.noReadingForRequestedHour) {
            try await provider().weather(for: .tokyo, at: WeatherTestDates.outsideFixture)
        }
    }

    @Test("Requests UTC so hours line up with instants")
    func requestsUTC() {
        let url = OpenMeteoProvider.url(for: .tokyo).absoluteString
        #expect(url.contains("timezone=UTC"))
        #expect(url.contains("latitude=35.68"))
        #expect(url.contains("cloud_cover_low"))
    }

    @Test("Carries the credit Open-Meteo asks for")
    func attribution() {
        #expect(provider().attribution.text == "Weather data by Open-Meteo.com")
        #expect(provider().attribution.url != nil)
    }
}
