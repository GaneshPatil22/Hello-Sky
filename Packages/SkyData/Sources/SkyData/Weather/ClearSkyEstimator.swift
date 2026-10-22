import Foundation
import SkyCore

/// Invents a plausible sky when there is no reading to be had.
///
/// Deliberately minimal: clear, dry, and no temperature. A made-up number
/// shown as a temperature would be a lie; an empty one is just missing.
public struct ClearSkyEstimator: Sendable {
    public init() {}

    public func weather(for place: Place, at date: Date) -> SkyWeather {
        SkyWeather(
            cloudCover: .clear,
            rain: 0,
            temperatureCelsius: nil,
            condition: .clear,
            fetched: date,
            origin: .estimated
        )
    }
}
