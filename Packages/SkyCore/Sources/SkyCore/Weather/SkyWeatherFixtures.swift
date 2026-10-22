import Foundation

extension SkyWeather {
    /// Readings covering the range the renderer has to handle.
    ///
    /// They live here, beside the model, because the sky renderer needs sample
    /// weather and must not depend on where real weather comes from.
    public enum Samples {
        public static func clear(at date: Date = .now) -> SkyWeather {
            SkyWeather(cloudCover: .clear, rain: 0, temperatureCelsius: 21,
                       condition: .clear, fetched: date, origin: .live)
        }

        public static func partlyCloudy(at date: Date = .now) -> SkyWeather {
            SkyWeather(cloudCover: CloudCover(total: 0.45, low: 0.3, middle: 0.2, high: 0.1),
                       rain: 0, temperatureCelsius: 17, condition: .partlyCloudy,
                       fetched: date, origin: .live)
        }

        public static func overcast(at date: Date = .now) -> SkyWeather {
            SkyWeather(cloudCover: CloudCover(total: 0.95, low: 0.9, middle: 0.6, high: 0.3),
                       rain: 0, temperatureCelsius: 11, condition: .overcast,
                       fetched: date, origin: .live)
        }

        public static func raining(at date: Date = .now) -> SkyWeather {
            SkyWeather(cloudCover: CloudCover(total: 0.85, low: 0.8, middle: 0.5, high: 0.2),
                       rain: 0.6, temperatureCelsius: 6, condition: .rain,
                       fetched: date, origin: .live)
        }

        public static func estimated(at date: Date = .now) -> SkyWeather {
            SkyWeather(cloudCover: .clear, rain: 0, temperatureCelsius: nil,
                       condition: .clear, fetched: date, origin: .estimated)
        }

        public static func all(at date: Date = .now) -> [SkyWeather] {
            [clear(at: date), partlyCloudy(at: date), overcast(at: date), raining(at: date)]
        }
    }
}
