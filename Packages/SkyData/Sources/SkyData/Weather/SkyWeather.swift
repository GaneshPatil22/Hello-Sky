import Foundation

/// The weather, as the rest of the app sees it.
///
/// This is the only weather type that leaves `SkyData`. Provider JSON shapes,
/// units, and vendor condition names all stop at the provider boundary.
public struct SkyWeather: Hashable, Sendable, Codable {
    public let cloudCover: CloudCover
    /// Rain intensity from 0 to 1, not an amount in millimetres.
    public let rain: Double
    /// Air temperature in Celsius, or `nil` when the reading is an estimate.
    public let temperatureCelsius: Double?
    public let condition: WeatherCondition
    /// When the reading was taken, which is not when it was asked for.
    public let fetched: Date
    public let origin: WeatherOrigin

    public init(
        cloudCover: CloudCover,
        rain: Double,
        temperatureCelsius: Double?,
        condition: WeatherCondition,
        fetched: Date,
        origin: WeatherOrigin
    ) {
        self.cloudCover = cloudCover
        self.rain = rain.clampedToFraction
        self.temperatureCelsius = temperatureCelsius
        self.condition = condition
        self.fetched = fetched
        self.origin = origin
    }
}

extension SkyWeather {
    /// The temperature as a measurement, so it formats in the reader's units.
    public var temperature: Measurement<UnitTemperature>? {
        temperatureCelsius.map { Measurement(value: $0, unit: UnitTemperature.celsius) }
    }

    /// A copy marked as having come from somewhere else.
    public func marked(as origin: WeatherOrigin) -> SkyWeather {
        SkyWeather(
            cloudCover: cloudCover,
            rain: rain,
            temperatureCelsius: temperatureCelsius,
            condition: condition,
            fetched: fetched,
            origin: origin
        )
    }
}
