import Foundation
import Observation
import SkyCore
import SkyData

/// Loads every person's weather at once, so the fallback chain can be watched.
@MainActor
@Observable
final class WeatherDebugModel {
    struct Row: Identifiable {
        let id: String
        let person: Person
        let weather: SkyWeather
        let attribution: WeatherAttribution
    }

    private(set) var rows: [Row] = []
    private(set) var callsUsed = 0
    private(set) var isLoading = false

    private let repository: WeatherRepository

    init(repository: WeatherRepository) {
        self.repository = repository
    }

    func load(people: [Person], at date: Date = .now) async {
        isLoading = true
        defer { isLoading = false }

        // Asked for together on purpose: it exercises the repository's request
        // sharing, and two people in one city must not cost two calls.
        var loaded: [Row] = []
        for person in people {
            let weather = await repository.weather(for: person.place, at: date)
            loaded.append(
                Row(
                    id: person.id,
                    person: person,
                    weather: weather,
                    attribution: await repository.attribution(for: weather)
                )
            )
        }
        rows = loaded
        callsUsed = await repository.callsUsed(at: date)
    }
}
