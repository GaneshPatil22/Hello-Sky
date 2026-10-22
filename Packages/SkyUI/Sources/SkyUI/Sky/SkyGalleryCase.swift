import Foundation
import SkyCore

/// One cell of the gallery: a place, a moment, and a sky to show.
public struct SkyGalleryCase: Hashable, Sendable, Identifiable {
    public let id: String
    public let place: Place
    public let date: Date
    public let weather: SkyWeather
    public let label: String

    public init(place: Place, date: Date, weather: SkyWeather, label: String) {
        self.id = "\(place.id)-\(date.timeIntervalSince1970)-\(weather.condition.rawValue)"
        self.place = place
        self.date = date
        self.weather = weather
        self.label = label
    }
}

extension SkyGalleryCase {
    /// The cities the gallery steps through.
    public static let places: [Place] = [
        PersonFixtures.you.place,     // London, temperate and northern
        PersonFixtures.kenji.place,   // Tokyo, mid-latitude
        PersonFixtures.mom.place,     // Reykjavik, near-polar
        PersonFixtures.dad.place,     // Sydney, southern hemisphere
    ]

    /// Six moments through one day, in UTC.
    public static let hours = [0, 5, 7, 12, 17, 21]

    /// A fixed day, so the gallery looks the same every time it is opened.
    public static let referenceDay = try! Date("2026-06-21T00:00:00Z", strategy: .iso8601)

    public static func cases(for place: Place, weather: SkyWeather) -> [SkyGalleryCase] {
        hours.map { hour in
            let date = referenceDay.addingTimeInterval(Double(hour) * 3_600)
            return SkyGalleryCase(place: place, date: date, weather: weather, label: "\(hour):00 UTC")
        }
    }

    /// The dozen fixed cases the snapshot tests cover: every city at three
    /// telling moments — deep night, sunrise, and midday.
    public static let snapshotCases: [SkyGalleryCase] = {
        let tellingHours = [0, 7, 12]
        return places.flatMap { place in
            tellingHours.map { hour in
                let date = referenceDay.addingTimeInterval(Double(hour) * 3_600)
                return SkyGalleryCase(
                    place: place,
                    date: date,
                    weather: SkyWeather.Samples.partlyCloudy(at: date),
                    label: "\(place.city) \(hour):00"
                )
            }
        }
    }()
}
