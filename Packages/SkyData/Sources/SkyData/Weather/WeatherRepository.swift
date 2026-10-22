import Foundation
import SkyCore

/// The one place the app asks about weather.
///
/// The seam for *behaviour*. It owns the cache, shares one request between
/// callers asking the same thing, counts calls against a daily budget, and
/// always answers: live, then cache, then an estimate. Because it cannot fail,
/// no screen needs an error path for weather.
public actor WeatherRepository {
    private let provider: any WeatherProvider
    private let cache: any WeatherCaching
    private let budget: WeatherBudget
    private let estimator: ClearSkyEstimator
    private let freshFor: TimeInterval

    /// One task per key, so two screens asking at once make one request.
    private var inFlight: [WeatherCacheKey: Task<SkyWeather, any Error>] = [:]

    public init(
        provider: any WeatherProvider,
        cache: any WeatherCaching = InMemoryWeatherCache(),
        budget: WeatherBudget = WeatherBudget(),
        estimator: ClearSkyEstimator = ClearSkyEstimator(),
        freshFor: TimeInterval = Defaults.freshFor
    ) {
        self.provider = provider
        self.cache = cache
        self.budget = budget
        self.estimator = estimator
        self.freshFor = freshFor
    }

    /// The weather at `place` for the hour containing `date`. Never fails.
    public func weather(for place: Place, at date: Date = .now) async -> SkyWeather {
        let key = WeatherCacheKey(placeID: place.id, date: date)

        if let cached = await cache.reading(for: key), isFresh(cached, at: date) {
            return cached.marked(as: .cache)
        }
        if await budget.claimCall(at: date) {
            if let fetched = try? await fetchSharingWork(for: place, key: key, at: date) {
                return fetched
            }
        }
        // Out of budget, or the provider could not be reached: anything in the
        // cache beats an estimate, however old it is.
        if let stale = await cache.reading(for: key) {
            return stale.marked(as: .cache)
        }
        return estimator.weather(for: place, at: date)
    }

    /// The credit to show beside a reading.
    ///
    /// An estimate never carries a weather service's name, which is what keeps
    /// the attribution honest when the network is off.
    public func attribution(for weather: SkyWeather) -> WeatherAttribution {
        weather.origin == .estimated ? .estimated : provider.attribution
    }

    public var providerAttribution: WeatherAttribution {
        provider.attribution
    }

    public func callsUsed(at date: Date = .now) async -> Int {
        await budget.callsUsed(at: date)
    }

    private func fetchSharingWork(for place: Place, key: WeatherCacheKey, at date: Date) async throws -> SkyWeather {
        if let existing = inFlight[key] {
            return try await existing.value
        }
        let task = Task { [provider, cache] in
            let weather = try await provider.weather(for: place, at: date)
            await cache.store(weather, for: key)
            return weather
        }
        inFlight[key] = task
        defer { inFlight[key] = nil }
        return try await task.value
    }

    private func isFresh(_ weather: SkyWeather, at date: Date) -> Bool {
        date.timeIntervalSince(weather.fetched) < freshFor
    }
}

extension WeatherRepository {
    public enum Defaults {
        /// Weather barely moves inside an hour, and the cache is keyed by hour
        /// anyway, so this is about refetching a reading taken at the hour's start.
        public static let freshFor: TimeInterval = 30 * 60
    }
}
