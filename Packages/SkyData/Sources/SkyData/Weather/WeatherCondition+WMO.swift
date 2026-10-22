import Foundation
import SkyCore

extension WeatherCondition {
    /// Maps a WMO weather code, which is what Open-Meteo reports.
    ///
    /// The full table is finer than this app needs, so neighbouring codes
    /// collapse into the one word a chip can show.
    init(wmoCode code: Int?) {
        switch code {
        case 0: self = .clear
        case 1: self = .mostlyClear
        case 2: self = .partlyCloudy
        case 3: self = .overcast
        case 45, 48: self = .fog
        case 51, 53, 55, 56, 57: self = .drizzle
        case 61, 63, 65, 66, 67, 80, 81, 82: self = .rain
        case 71, 73, 75, 77, 85, 86: self = .snow
        case 95, 96, 99: self = .thunderstorm
        default: self = .cloudy
        }
    }
}
