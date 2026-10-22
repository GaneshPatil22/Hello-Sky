import Foundation

/// The weather in one word, for a chip and for picking what to draw.
///
/// A small closed set rather than a source's own vocabulary, so every provider
/// maps into the same thing and no screen ever sees a vendor's wording.
public enum WeatherCondition: String, Hashable, Sendable, Codable, CaseIterable {
    case clear
    case mostlyClear
    case partlyCloudy
    case cloudy
    case overcast
    case fog
    case drizzle
    case rain
    case snow
    case thunderstorm

    /// Whether this condition puts something falling in the sky.
    public var isPrecipitating: Bool {
        switch self {
        case .drizzle, .rain, .snow, .thunderstorm: true
        case .clear, .mostlyClear, .partlyCloudy, .cloudy, .overcast, .fog: false
        }
    }

    public var label: LocalizedStringResource {
        switch self {
        case .clear: "Clear"
        case .mostlyClear: "Mostly clear"
        case .partlyCloudy: "Partly cloudy"
        case .cloudy: "Cloudy"
        case .overcast: "Overcast"
        case .fog: "Fog"
        case .drizzle: "Drizzle"
        case .rain: "Rain"
        case .snow: "Snow"
        case .thunderstorm: "Thunderstorm"
        }
    }
}
