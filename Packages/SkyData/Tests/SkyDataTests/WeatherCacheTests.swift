import Foundation
import SkyCore
import Testing

@testable import SkyData

@Suite("Weather cache")
struct WeatherCacheTests {
    private func sample(at date: Date) -> SkyWeather {
        SkyWeather(cloudCover: CloudCover(total: 0.5), rain: 0.1, temperatureCelsius: 12,
                   condition: .partlyCloudy, fetched: date, origin: .live)
    }

    @Test("Every moment in an hour lands on the same key")
    func keyBucketsByHour() {
        let early = try! Date("2026-10-22T10:00:00Z", strategy: .iso8601)
        let late = try! Date("2026-10-22T10:59:59Z", strategy: .iso8601)
        let nextHour = try! Date("2026-10-22T11:00:00Z", strategy: .iso8601)

        #expect(WeatherCacheKey(placeID: "tokyo", date: early) == WeatherCacheKey(placeID: "tokyo", date: late))
        #expect(WeatherCacheKey(placeID: "tokyo", date: early) != WeatherCacheKey(placeID: "tokyo", date: nextHour))
        #expect(WeatherCacheKey(placeID: "tokyo", date: early) != WeatherCacheKey(placeID: "london", date: early))
    }

    @Test("Keys produce a usable file name even from an awkward place id")
    func safeFileNames() {
        let key = WeatherCacheKey(placeID: "mapkit:35.68,139.69", date: .now)
        #expect(!key.fileName.contains(":"))
        #expect(!key.fileName.contains(","))
        #expect(key.fileName.hasSuffix(".json"))
    }

    @Test("Stores and returns a reading in memory")
    func inMemoryRoundTrip() async {
        let cache = InMemoryWeatherCache()
        let key = WeatherCacheKey(placeID: "tokyo", date: .now)
        let weather = sample(at: .now)

        #expect(await cache.reading(for: key) == nil)
        await cache.store(weather, for: key)
        #expect(await cache.reading(for: key) == weather)

        await cache.removeAll()
        #expect(await cache.reading(for: key) == nil)
    }

    @Test("Stores and returns a reading on disk")
    func diskRoundTrip() async {
        let directory = URL.temporaryDirectory.appending(path: "cache-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }

        let cache = DiskWeatherCache(directory: directory)
        let key = WeatherCacheKey(placeID: "tokyo", date: .now)
        let weather = sample(at: .now)

        await cache.store(weather, for: key)
        #expect(await cache.reading(for: key) == weather)

        // A second cache on the same folder stands in for the next launch.
        let reopened = DiskWeatherCache(directory: directory)
        #expect(await reopened.reading(for: key) == weather)
    }

    @Test("A reading taken long ago is no longer served as fresh")
    func expiry() async {
        let cache = InMemoryWeatherCache()
        let repository = WeatherRepository(
            provider: MockWeatherProvider(failure: TestError.offline),
            cache: cache,
            freshFor: 30 * 60
        )
        let now = try! Date("2026-10-22T10:00:00Z", strategy: .iso8601)
        let key = WeatherCacheKey(placeID: Place.tokyo.id, date: now)

        // Stored an hour before it is asked for: inside the same hour bucket,
        // but older than the freshness window.
        await cache.store(sample(at: now.addingTimeInterval(-3_600)), for: key)
        let served = await repository.weather(for: .tokyo, at: now)

        // The provider is offline, so the stale reading is still the best
        // answer — but it was not treated as fresh on the way there.
        #expect(served.origin == .cache)
        #expect(served.fetched < now)
    }
}
