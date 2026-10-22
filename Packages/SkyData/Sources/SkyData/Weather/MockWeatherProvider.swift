import Foundation
import SkyCore

/// Fixed weather for previews, tests, and offline work.
///
/// Readings come from the prototype's cast, keyed by city, so Reykjavik is
/// always raining and Sydney is always clear. Anywhere else gets a reading
/// derived from its own id, which keeps results stable between runs.
public struct MockWeatherProvider: WeatherProvider {
    public let attribution = WeatherAttribution(text: "Sample data")

    /// Set to make every call fail, for testing what the repository does then.
    public let failure: (any Error)?

    public init(failure: (any Error)? = nil) {
        self.failure = failure
    }

    public func weather(for place: Place, at date: Date) async throws -> SkyWeather {
        if let failure { throw failure }
        return Self.reading(for: place, at: date)
    }

    static func reading(for place: Place, at date: Date) -> SkyWeather {
        let sample = WeatherFixtures.byCityID[place.id] ?? WeatherFixtures.derived(for: place.id)
        return SkyWeather(
            cloudCover: sample.cloudCover,
            rain: sample.rain,
            temperatureCelsius: sample.temperatureCelsius,
            condition: sample.condition,
            fetched: date,
            origin: .live
        )
    }
}
