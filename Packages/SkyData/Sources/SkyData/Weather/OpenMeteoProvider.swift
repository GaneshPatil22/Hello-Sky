import Foundation
import SkyCore

/// Weather from Open-Meteo, used while developing.
///
/// Free for non-commercial use with no key, and with no service guarantee,
/// which is why the release build moves to WeatherKit in Phase 8.
public struct OpenMeteoProvider: WeatherProvider {
    public let attribution = WeatherAttribution(
        text: "Weather data by Open-Meteo.com",
        url: URL(string: "https://open-meteo.com")
    )

    private let loader: any HTTPLoading

    public init(loader: any HTTPLoading = URLSessionLoader()) {
        self.loader = loader
    }

    public func weather(for place: Place, at date: Date) async throws -> SkyWeather {
        let data = try await loader.data(from: Self.url(for: place))
        let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        return try Self.reading(from: response.hourly, at: date)
    }

    static func url(for place: Place) -> URL {
        var components = URLComponents(string: Endpoint.forecast)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(place.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(place.coordinate.longitude)),
            URLQueryItem(name: "hourly", value: Endpoint.hourlyFields.joined(separator: ",")),
            URLQueryItem(name: "forecast_days", value: String(Endpoint.forecastDays)),
            // UTC throughout, so the row to use is found by comparing instants
            // rather than by trusting a local-time string.
            URLQueryItem(name: "timezone", value: "UTC"),
        ]
        return components.url!
    }

    /// Picks the hour containing `date` and maps it into `SkyWeather`.
    static func reading(from hourly: OpenMeteoResponse.Hourly, at date: Date) throws -> SkyWeather {
        guard let index = index(of: date, in: hourly.time) else {
            throw OpenMeteoError.noReadingForRequestedHour
        }
        let percent = { (series: [Double?]?) -> Double? in
            series?.indices.contains(index) == true ? series?[index].map { $0 / 100 } : nil
        }
        let code = hourly.weatherCode.indices.contains(index) ? hourly.weatherCode[index] : nil
        let precipitation = hourly.precipitation.indices.contains(index)
            ? (hourly.precipitation[index] ?? 0) : 0

        return SkyWeather(
            cloudCover: CloudCover(
                total: percent(hourly.cloudCover) ?? 0,
                low: percent(hourly.cloudCoverLow),
                middle: percent(hourly.cloudCoverMid),
                high: percent(hourly.cloudCoverHigh)
            ),
            rain: min(precipitation / Scale.heavyRainMillimetres, 1),
            temperatureCelsius: hourly.temperature2m.indices.contains(index)
                ? hourly.temperature2m[index] : nil,
            condition: WeatherCondition(wmoCode: code),
            fetched: date,
            origin: .live
        )
    }

    /// Open-Meteo returns local-naive hour strings; with `timezone=UTC` they are UTC.
    private static func index(of date: Date, in times: [String]) -> Int? {
        let wanted = Self.hourFormatter.string(from: date)
        return times.firstIndex(of: wanted)
    }

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        // A fixed format for machine exchange, not for display.
        formatter.dateFormat = "yyyy-MM-dd'T'HH':00'"
        return formatter
    }()
}

extension OpenMeteoProvider {
    enum Endpoint {
        static let forecast = "https://api.open-meteo.com/v1/forecast"
        static let hourlyFields = [
            "temperature_2m", "cloud_cover", "cloud_cover_low",
            "cloud_cover_mid", "cloud_cover_high", "precipitation", "weather_code",
        ]
        static let forecastDays = 2
    }

    enum Scale {
        /// Millimetres in an hour that counts as rain at full intensity.
        static let heavyRainMillimetres = 5.0
    }
}

public enum OpenMeteoError: Error, Equatable {
    case noReadingForRequestedHour
}
