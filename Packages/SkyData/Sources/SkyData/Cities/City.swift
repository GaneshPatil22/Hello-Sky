import Foundation
import SkyCore

/// A city someone can be placed in.
public struct City: Hashable, Sendable, Codable, Identifiable {
    public let id: String
    public let name: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let timeZoneIdentifier: String

    public init(
        id: String,
        name: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

extension City {
    public var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }

    /// The engine's view of this city.
    public var place: Place {
        Place(id: id, city: name, coordinate: coordinate, timeZoneIdentifier: timeZoneIdentifier)
    }

    /// "Tokyo, Japan", for a search result row.
    public var qualifiedName: String {
        "\(name), \(country)"
    }
}
