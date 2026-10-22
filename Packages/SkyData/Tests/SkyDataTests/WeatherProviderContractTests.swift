import Foundation
import SkyCore
import Testing

@testable import SkyData

/// The same assertions run against every source.
///
/// This is what makes the provider seam real: a new source passes these or it
/// is not a provider. `SharedCacheProvider` is here from the start to prove
/// that adding one needs no change to the repository or to any screen.
@Suite("Weather provider contract")
struct WeatherProviderContractTests {
    private static let date = try! Date("2026-10-22T10:00:00Z", strategy: .iso8601)

    static let providers: [(name: String, provider: any WeatherProvider)] = [
        ("mock", MockWeatherProvider()),
        ("open-meteo", OpenMeteoProvider(loader: StubLoader(fixture: "open-meteo-tokyo"))),
        ("shared-cache stub", SharedCacheProvider()),
    ]

    @Test("Every provider returns a well-formed reading", arguments: providers.map(\.name))
    func returnsWellFormedReading(name: String) async throws {
        let provider = Self.providers.first { $0.name == name }!.provider
        let weather = try await provider.weather(for: .tokyo, at: Self.date)

        #expect(weather.cloudCover.total >= 0 && weather.cloudCover.total <= 1, "\(name) cloud cover")
        #expect(weather.rain >= 0 && weather.rain <= 1, "\(name) rain")
        #expect(weather.origin == .live, "\(name) origin")
        for layer in [weather.cloudCover.low, weather.cloudCover.middle, weather.cloudCover.high] {
            if let layer { #expect(layer >= 0 && layer <= 1, "\(name) layer") }
        }
    }

    @Test("Every provider supplies its own credit", arguments: providers.map(\.name))
    func suppliesAttribution(name: String) {
        let provider = Self.providers.first { $0.name == name }!.provider
        #expect(!provider.attribution.text.isEmpty, "\(name) has no attribution")
    }

    @Test("Every provider works behind the repository without changing it", arguments: providers.map(\.name))
    func worksBehindTheRepository(name: String) async {
        let provider = Self.providers.first { $0.name == name }!.provider
        let repository = WeatherRepository(provider: provider, cache: InMemoryWeatherCache())

        let weather = await repository.weather(for: .tokyo, at: Self.date)
        #expect(weather.origin == .live, "\(name) did not reach the repository")
        #expect(await repository.attribution(for: weather).text == provider.attribution.text)
    }
}
