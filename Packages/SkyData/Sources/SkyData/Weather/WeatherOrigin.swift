import Foundation

/// Where a reading came from.
///
/// Carried so the app can be honest: an estimate must never be shown under a
/// weather service's attribution, and a stale reading can say when it was taken.
public enum WeatherOrigin: String, Hashable, Sendable, Codable {
    /// Straight from the provider.
    case live
    /// From the on-device cache, because the provider could not be reached or
    /// the daily budget was spent.
    case cache
    /// Computed from the astronomy engine, because there was nothing else.
    case estimated
}
