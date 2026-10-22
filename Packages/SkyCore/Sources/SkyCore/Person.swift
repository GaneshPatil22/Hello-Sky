import Foundation

/// Someone whose sky you follow.
///
/// This is the plain model the engine works with. Phase 2 adds a SwiftData
/// model that maps to and from this type.
public struct Person: Hashable, Sendable, Codable, Identifiable {
    public let id: String
    public let name: String
    public let avatar: Avatar
    public let place: Place
    public let awakeHours: AwakeHours

    public init(id: String, name: String, avatar: Avatar, place: Place, awakeHours: AwakeHours) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.place = place
        self.awakeHours = awakeHours
    }
}

/// How a person is pictured.
///
/// v1 ships emoji only. Storing the kind rather than a bare string means photo
/// avatars in v2 need no data migration.
public enum Avatar: Hashable, Sendable, Codable {
    case emoji(String)
}
