import Foundation
import Observation
import SkyCore
import SkyData

/// What the sky screen needs to know, loaded once and refreshed as time moves.
@MainActor
@Observable
final class SkyDetailModel {
    private(set) var weather: SkyWeather
    private(set) var attribution: WeatherAttribution

    private let repository: WeatherRepository
    private let place: Place

    init(place: Place, repository: WeatherRepository) {
        self.place = place
        self.repository = repository
        // Starts on an estimate so the sky draws immediately; the real reading
        // replaces it a moment later without the screen ever being empty.
        self.weather = SkyWeather.Samples.estimated()
        self.attribution = .estimated
    }

    func load(at date: Date) async {
        let reading = await repository.weather(for: place, at: date)
        weather = reading
        attribution = await repository.attribution(for: reading)
    }
}
