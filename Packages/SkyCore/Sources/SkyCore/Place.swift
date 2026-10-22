import Foundation

/// A named location on Earth with the time zone its clocks follow.
public struct Place: Hashable, Sendable, Codable, Identifiable {
    public let id: String
    public let city: String
    public let coordinate: Coordinate
    /// An IANA identifier, such as `Europe/London`.
    public let timeZoneIdentifier: String

    public init(id: String, city: String, coordinate: Coordinate, timeZoneIdentifier: String) {
        self.id = id
        self.city = city
        self.coordinate = coordinate
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    /// The time zone named by `timeZoneIdentifier`, or `nil` if the system does not know it.
    public var timeZone: TimeZone? {
        TimeZone(identifier: timeZoneIdentifier)
    }
}
