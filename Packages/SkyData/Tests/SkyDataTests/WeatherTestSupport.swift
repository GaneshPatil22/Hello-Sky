import Foundation
import SkyCore
import Testing

@testable import SkyData

/// Serves a saved response instead of the network.
struct StubLoader: HTTPLoading {
    let data: Data
    let failure: (any Error)?

    init(fixture: String) {
        let url = Bundle.module.url(forResource: fixture, withExtension: "json")!
        data = try! Data(contentsOf: url)
        failure = nil
    }

    init(failure: any Error) {
        self.data = Data()
        self.failure = failure
    }

    func data(from url: URL) async throws -> Data {
        if let failure { throw failure }
        return data
    }
}

/// The shared one-call-per-city service the plan keeps in reserve.
///
/// A stub, present from Phase 3 so the claim that a new source needs no
/// repository or screen change is tested rather than asserted.
struct SharedCacheProvider: WeatherProvider {
    let attribution = WeatherAttribution(text: "Weather data via Hello Sky's shared cache")

    func weather(for place: Place, at date: Date) async throws -> SkyWeather {
        SkyWeather(
            cloudCover: CloudCover(total: 0.4, low: 0.2, middle: 0.1, high: 0.1),
            rain: 0,
            temperatureCelsius: 17,
            condition: .partlyCloudy,
            fetched: date,
            origin: .live
        )
    }
}

/// Counts calls, so request sharing can be observed.
actor CountingProvider: WeatherProvider {
    nonisolated let attribution = WeatherAttribution(text: "Counting")
    private var calls = 0
    private let delay: Duration

    init(delay: Duration = .milliseconds(20)) {
        self.delay = delay
    }

    func callCount() -> Int { calls }

    func weather(for place: Place, at date: Date) async throws -> SkyWeather {
        calls += 1
        try? await Task.sleep(for: delay)
        return SkyWeather(
            cloudCover: CloudCover(total: 0.5),
            rain: 0,
            temperatureCelsius: 12,
            condition: .partlyCloudy,
            fetched: date,
            origin: .live
        )
    }
}

enum TestError: Error, Equatable {
    case offline
}

enum WeatherTestDates {
    /// Inside the saved Open-Meteo fixture's range.
    static let insideFixture = try! Date("2026-10-22T10:00:00Z", strategy: .iso8601)
    static let rainyHour = try! Date("2026-10-22T20:00:00Z", strategy: .iso8601)
    static let heavyRainHour = try! Date("2026-10-22T21:00:00Z", strategy: .iso8601)
    static let foggyHour = try! Date("2026-10-22T03:00:00Z", strategy: .iso8601)
    static let outsideFixture = try! Date("2027-01-01T00:00:00Z", strategy: .iso8601)
}

extension Place {
    static let tokyo = CityCatalog.cities(matching: "Tokyo").first { $0.name == "Tokyo" }!.place
    static let london = CityCatalog.cities(matching: "London").first { $0.name == "London" }!.place
}
