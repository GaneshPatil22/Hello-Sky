import Foundation
import SkyCore
import SwiftData

/// How a person is kept on the device.
///
/// Every property has a default and nothing is marked unique. Both are for the
/// iCloud sync planned in v2: CloudKit rejects unique attributes and requires
/// defaults, and paying that cost now avoids a migration later.
@Model
public final class StoredPerson {
    public var id: String = ""
    public var name: String = ""
    /// Stored as kind plus value so v2 can add photos without a migration.
    public var avatarKind: String = StoredAvatarKind.emoji.rawValue
    public var avatarValue: String = ""
    public var cityID: String = ""
    public var cityName: String = ""
    public var latitude: Double = 0
    public var longitude: Double = 0
    public var timeZoneIdentifier: String = ""
    public var awakeStart: Double = AwakeHours.default.start
    public var awakeEnd: Double = AwakeHours.default.end
    /// The order the list shows, kept so people do not shuffle on every launch.
    public var sortOrder: Int = 0

    public init(
        id: String,
        name: String,
        avatarKind: String,
        avatarValue: String,
        cityID: String,
        cityName: String,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String,
        awakeStart: Double,
        awakeEnd: Double,
        sortOrder: Int
    ) {
        self.id = id
        self.name = name
        self.avatarKind = avatarKind
        self.avatarValue = avatarValue
        self.cityID = cityID
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
        self.awakeStart = awakeStart
        self.awakeEnd = awakeEnd
        self.sortOrder = sortOrder
    }
}

/// The kinds of avatar the store understands.
public enum StoredAvatarKind: String, Sendable, CaseIterable {
    case emoji
    // v2 adds `photo`, whose value becomes an asset identifier.
}
