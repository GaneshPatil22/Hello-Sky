import Foundation

/// A cache that lives only as long as the process. For tests and previews.
public actor InMemoryWeatherCache: WeatherCaching {
    private var readings: [WeatherCacheKey: SkyWeather] = [:]

    public init() {}

    public func reading(for key: WeatherCacheKey) async -> SkyWeather? {
        readings[key]
    }

    public func store(_ weather: SkyWeather, for key: WeatherCacheKey) async {
        readings[key] = weather
    }

    public func removeAll() async {
        readings.removeAll()
    }
}
