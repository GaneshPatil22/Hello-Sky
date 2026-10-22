import Foundation
import SkyCore

extension StoredPerson {
    /// The engine's view of this record.
    ///
    /// Returns `nil` when the row cannot make a usable person — an unknown
    /// avatar kind, or a time zone this system does not have — so a corrupt or
    /// future-versioned row is skipped rather than crashing the list.
    public var person: Person? {
        guard let kind = StoredAvatarKind(rawValue: avatarKind), TimeZone(identifier: timeZoneIdentifier) != nil else {
            return nil
        }
        let avatar: Avatar = switch kind {
        case .emoji: .emoji(avatarValue)
        }
        return Person(
            id: id,
            name: name,
            avatar: avatar,
            place: Place(
                id: cityID,
                city: cityName,
                coordinate: Coordinate(latitude: latitude, longitude: longitude),
                timeZoneIdentifier: timeZoneIdentifier
            ),
            awakeHours: AwakeHours(start: awakeStart, end: awakeEnd)
        )
    }

    public convenience init(person: Person, sortOrder: Int) {
        let kind: StoredAvatarKind
        let value: String
        switch person.avatar {
        case .emoji(let emoji):
            kind = .emoji
            value = emoji
        }
        self.init(
            id: person.id,
            name: person.name,
            avatarKind: kind.rawValue,
            avatarValue: value,
            cityID: person.place.id,
            cityName: person.place.city,
            latitude: person.place.coordinate.latitude,
            longitude: person.place.coordinate.longitude,
            timeZoneIdentifier: person.place.timeZoneIdentifier,
            awakeStart: person.awakeHours.start,
            awakeEnd: person.awakeHours.end,
            sortOrder: sortOrder
        )
    }

    /// Writes `person`'s fields onto this record, keeping its place in the list.
    public func update(from person: Person) {
        let replacement = StoredPerson(person: person, sortOrder: sortOrder)
        name = replacement.name
        avatarKind = replacement.avatarKind
        avatarValue = replacement.avatarValue
        cityID = replacement.cityID
        cityName = replacement.cityName
        latitude = replacement.latitude
        longitude = replacement.longitude
        timeZoneIdentifier = replacement.timeZoneIdentifier
        awakeStart = replacement.awakeStart
        awakeEnd = replacement.awakeEnd
    }
}
