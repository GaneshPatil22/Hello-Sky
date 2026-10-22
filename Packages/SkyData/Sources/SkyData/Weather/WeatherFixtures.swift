import Foundation

/// Sample weather, matching the prototype's cast.
public enum WeatherFixtures {
    public struct Sample: Hashable, Sendable {
        public let cloudCover: CloudCover
        public let rain: Double
        public let temperatureCelsius: Double
        public let condition: WeatherCondition
    }

    public static let byCityID: [String: Sample] = [
        "london": Sample(cloudCover: CloudCover(total: 0.62, low: 0.5, middle: 0.3, high: 0.2),
                         rain: 0, temperatureCelsius: 11, condition: .overcast),
        "new-york": Sample(cloudCover: CloudCover(total: 0.30, low: 0.2, middle: 0.1, high: 0.1),
                           rain: 0, temperatureCelsius: 14, condition: .partlyCloudy),
        "sydney": Sample(cloudCover: CloudCover(total: 0.08, low: 0, middle: 0, high: 0.08),
                         rain: 0, temperatureCelsius: 23, condition: .clear),
        "tokyo": Sample(cloudCover: CloudCover(total: 0.45, low: 0.3, middle: 0.2, high: 0.1),
                        rain: 0, temperatureCelsius: 18, condition: .partlyCloudy),
        "rio-de-janeiro": Sample(cloudCover: CloudCover(total: 0.25, low: 0.1, middle: 0.1, high: 0.1),
                                 rain: 0, temperatureCelsius: 27, condition: .mostlyClear),
        "nairobi": Sample(cloudCover: CloudCover(total: 0.20, low: 0.1, middle: 0.1, high: 0.05),
                          rain: 0, temperatureCelsius: 22, condition: .mostlyClear),
        "reykjavik": Sample(cloudCover: CloudCover(total: 0.78, low: 0.7, middle: 0.4, high: 0.2),
                            rain: 0.55, temperatureCelsius: 6, condition: .rain),
        "mumbai": Sample(cloudCover: CloudCover(total: 0.35, low: 0.2, middle: 0.2, high: 0.1),
                         rain: 0, temperatureCelsius: 31, condition: .partlyCloudy),
    ]

    /// A stable reading for a city with no sample, derived from its id so the
    /// same place always looks the same.
    public static func derived(for cityID: String) -> Sample {
        let seed = abs(cityID.hashValue)
        let cover = Double(seed % 100) / 100
        return Sample(
            cloudCover: CloudCover(total: cover),
            rain: cover > Thresholds.rainingAbove ? (cover - Thresholds.rainingAbove) * 2 : 0,
            temperatureCelsius: Double(seed % 35) - 5,
            condition: condition(forCover: cover)
        )
    }

    private static func condition(forCover cover: Double) -> WeatherCondition {
        switch cover {
        case ..<0.1: .clear
        case ..<0.3: .mostlyClear
        case ..<0.6: .partlyCloudy
        case ..<Thresholds.rainingAbove: .cloudy
        default: .rain
        }
    }

    enum Thresholds {
        static let rainingAbove = 0.85
    }
}
