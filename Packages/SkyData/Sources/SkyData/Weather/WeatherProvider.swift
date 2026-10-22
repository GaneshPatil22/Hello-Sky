import Foundation
import SkyCore

/// A source of weather.
///
/// The seam for *sources*. Each one maps its own data into `SkyWeather` and
/// supplies its own attribution, so adding WeatherKit or a shared cache later
/// touches nothing above this protocol.
public protocol WeatherProvider: Sendable {
    /// The credit this source requires beside its data.
    var attribution: WeatherAttribution { get }

    /// The weather at `place` for the hour containing `date`.
    func weather(for place: Place, at date: Date) async throws -> SkyWeather
}
