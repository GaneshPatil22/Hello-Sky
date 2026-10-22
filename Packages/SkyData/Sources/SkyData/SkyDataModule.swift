import Foundation
import SkyCore

/// Phase 0 scaffolding.
///
/// Phase 3 fills this module with `SkyWeather`, the `WeatherProvider` protocol,
/// and `WeatherRepository`. This file exists only so the module compiles and its
/// dependency on `SkyCore` is proven by a test from the first commit.
public enum SkyDataModule {
    static let referencePoint = Coordinate(latitude: 0, longitude: 0)

    /// Confirms this module links against `SkyCore`. Removed in Phase 3.
    public static func canReachSkyCore() -> Bool {
        referencePoint.isValid
    }
}
