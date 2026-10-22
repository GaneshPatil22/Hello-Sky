import Foundation

/// Which provider the app runs on.
///
/// Debug builds use Open-Meteo, which needs no key. The release build moves to
/// WeatherKit in Phase 8, when the paid membership exists; until then both
/// configurations use the same source, and this is the single place that changes.
public enum WeatherSource {
    public static func makeProvider() -> any WeatherProvider {
        #if DEBUG
        OpenMeteoProvider()
        #else
        // Phase 8 replaces this with WeatherKitProvider.
        OpenMeteoProvider()
        #endif
    }

    /// The repository the app runs on, with the on-disk cache.
    public static func makeRepository() -> WeatherRepository {
        WeatherRepository(provider: makeProvider(), cache: DiskWeatherCache())
    }
}
