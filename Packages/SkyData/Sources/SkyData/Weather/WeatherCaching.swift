import Foundation
import SkyCore

/// Where readings are kept between launches.
public protocol WeatherCaching: Sendable {
    func reading(for key: WeatherCacheKey) async -> SkyWeather?
    func store(_ weather: SkyWeather, for key: WeatherCacheKey) async
    func removeAll() async
}
