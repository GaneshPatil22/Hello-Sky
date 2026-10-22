import Foundation
import SkyCore
import Testing

@testable import SkyData

@Suite("Weather repository")
struct WeatherRepositoryTests {
    private let now = try! Date("2026-10-22T10:00:00Z", strategy: .iso8601)

    @Test("Returns a live reading and remembers it")
    func livesThenCaches() async {
        let cache = InMemoryWeatherCache()
        let repository = WeatherRepository(provider: MockWeatherProvider(), cache: cache)

        let first = await repository.weather(for: .tokyo, at: now)
        #expect(first.origin == .live)

        let second = await repository.weather(for: .tokyo, at: now)
        #expect(second.origin == .cache, "the second ask must not go out again")
        #expect(second.temperatureCelsius == first.temperatureCelsius)
    }

    @Test("Falls back to the cache when the provider cannot be reached")
    func fallsBackToCache() async {
        let cache = InMemoryWeatherCache()
        let working = WeatherRepository(provider: MockWeatherProvider(), cache: cache)
        let stored = await working.weather(for: .tokyo, at: now)

        let offline = WeatherRepository(
            provider: MockWeatherProvider(failure: TestError.offline),
            cache: cache,
            freshFor: 0 // force it past the cache's freshness check
        )
        let served = await offline.weather(for: .tokyo, at: now)

        #expect(served.origin == .cache)
        #expect(served.temperatureCelsius == stored.temperatureCelsius)
    }

    @Test("Falls back to a clear sky when there is nothing cached")
    func fallsBackToEstimate() async {
        let repository = WeatherRepository(
            provider: MockWeatherProvider(failure: TestError.offline),
            cache: InMemoryWeatherCache()
        )
        let served = await repository.weather(for: .tokyo, at: now)

        #expect(served.origin == .estimated)
        #expect(served.condition == .clear)
        #expect(served.cloudCover.total == 0)
        #expect(served.temperatureCelsius == nil, "an estimate must not invent a temperature")
    }

    @Test("Every person gets an answer with the network off")
    func everyoneAlwaysHasWeather() async {
        let repository = WeatherRepository(
            provider: MockWeatherProvider(failure: TestError.offline),
            cache: InMemoryWeatherCache()
        )
        for person in PersonFixtures.all {
            let weather = await repository.weather(for: person.place, at: now)
            #expect(weather.cloudCover.total >= 0, "\(person.place.city) had no reading")
        }
    }

    @Test("Stops calling out once the daily budget is spent")
    func respectsTheBudget() async {
        let repository = WeatherRepository(
            provider: MockWeatherProvider(),
            cache: InMemoryWeatherCache(),
            budget: WeatherBudget(dailyLimit: 1, now: now)
        )
        let first = await repository.weather(for: .tokyo, at: now)
        #expect(first.origin == .live)

        // A different city in the same hour needs a second call it cannot make.
        let second = await repository.weather(for: .london, at: now)
        #expect(second.origin == .estimated)
        #expect(await repository.callsUsed(at: now) == 1)
    }

    @Test("Two screens asking at once make one request")
    func sharesWorkInFlight() async {
        let provider = CountingProvider()
        let repository = WeatherRepository(provider: provider, cache: InMemoryWeatherCache())

        async let a = repository.weather(for: .tokyo, at: now)
        async let b = repository.weather(for: .tokyo, at: now)
        async let c = repository.weather(for: .tokyo, at: now)
        let readings = await [a, b, c]

        let calls = await provider.callCount()
        #expect(readings.allSatisfy { $0.origin != .estimated })
        #expect(calls == 1, "made \(calls) requests")
    }

    @Test("Different hours are fetched separately")
    func hoursAreDistinct() async {
        let provider = CountingProvider(delay: .zero)
        let repository = WeatherRepository(provider: provider, cache: InMemoryWeatherCache())

        _ = await repository.weather(for: .tokyo, at: now)
        _ = await repository.weather(for: .tokyo, at: now.addingTimeInterval(3_600))
        let calls = await provider.callCount()
        #expect(calls == 2, "made \(calls) requests")
    }

    @Test("An estimate never carries a weather service's name")
    func attributionIsHonest() async {
        let repository = WeatherRepository(
            provider: OpenMeteoProvider(loader: StubLoader(failure: TestError.offline)),
            cache: InMemoryWeatherCache()
        )
        let estimate = await repository.weather(for: .tokyo, at: now)
        let credit = await repository.attribution(for: estimate)

        #expect(estimate.origin == .estimated)
        #expect(credit == .estimated)
        #expect(credit.text != "Weather data by Open-Meteo.com")
    }

    @Test("A live reading carries the provider's own credit")
    func attributionFollowsTheProvider() async {
        let repository = WeatherRepository(provider: SharedCacheProvider(), cache: InMemoryWeatherCache())
        let weather = await repository.weather(for: .tokyo, at: now)

        #expect(await repository.attribution(for: weather).text.contains("shared cache"))
    }
}
