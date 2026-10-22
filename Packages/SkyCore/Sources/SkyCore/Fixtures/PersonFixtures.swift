import Foundation

/// Sample people for previews, tests, and debug seeding.
///
/// The first seven are the cast from the web prototype, kept so ported logic can
/// be compared against it directly. `priya` is added for the half-hour time zone
/// the prototype never covered.
public enum PersonFixtures {
    public static let you = Person(
        id: "you",
        name: "You",
        avatar: .emoji("🙂"),
        place: Place(id: "london", city: "London",
                     coordinate: Coordinate(latitude: 51.51, longitude: -0.13),
                     timeZoneIdentifier: "Europe/London"),
        awakeHours: AwakeHours(start: 7, end: 23)
    )

    public static let ava = Person(
        id: "ava",
        name: "Ava",
        avatar: .emoji("🦊"),
        place: Place(id: "new-york", city: "New York",
                     coordinate: Coordinate(latitude: 40.71, longitude: -74.0),
                     timeZoneIdentifier: "America/New_York"),
        awakeHours: AwakeHours(start: 8, end: 23)
    )

    public static let dad = Person(
        id: "dad",
        name: "Dad",
        avatar: .emoji("🧔"),
        place: Place(id: "sydney", city: "Sydney",
                     coordinate: Coordinate(latitude: -33.87, longitude: 151.21),
                     timeZoneIdentifier: "Australia/Sydney"),
        awakeHours: AwakeHours(start: 6, end: 22)
    )

    public static let kenji = Person(
        id: "kenji",
        name: "Kenji",
        avatar: .emoji("🎧"),
        place: Place(id: "tokyo", city: "Tokyo",
                     coordinate: Coordinate(latitude: 35.68, longitude: 139.69),
                     timeZoneIdentifier: "Asia/Tokyo"),
        awakeHours: AwakeHours(start: 8, end: 23)
    )

    public static let luz = Person(
        id: "luz",
        name: "Luz",
        avatar: .emoji("🌴"),
        place: Place(id: "rio-de-janeiro", city: "Rio de Janeiro",
                     coordinate: Coordinate(latitude: -22.91, longitude: -43.17),
                     timeZoneIdentifier: "America/Sao_Paulo"),
        awakeHours: AwakeHours(start: 9, end: 23)
    )

    public static let amara = Person(
        id: "amara",
        name: "Amara",
        avatar: .emoji("🦒"),
        place: Place(id: "nairobi", city: "Nairobi",
                     coordinate: Coordinate(latitude: -1.29, longitude: 36.82),
                     timeZoneIdentifier: "Africa/Nairobi"),
        awakeHours: AwakeHours(start: 7, end: 22)
    )

    /// Near-polar: Reykjavik exercises the long summer day and short winter one.
    public static let mom = Person(
        id: "mom",
        name: "Mom",
        avatar: .emoji("👩"),
        place: Place(id: "reykjavik", city: "Reykjavik",
                     coordinate: Coordinate(latitude: 64.15, longitude: -21.94),
                     timeZoneIdentifier: "Atlantic/Reykjavik"),
        awakeHours: AwakeHours(start: 7, end: 22)
    )

    /// Half-hour offset: India is UTC+5:30 and observes no daylight saving.
    public static let priya = Person(
        id: "priya",
        name: "Priya",
        avatar: .emoji("🪁"),
        place: Place(id: "mumbai", city: "Mumbai",
                     coordinate: Coordinate(latitude: 19.08, longitude: 72.88),
                     timeZoneIdentifier: "Asia/Kolkata"),
        awakeHours: AwakeHours(start: 7, end: 23)
    )

    /// Everyone, with `you` first.
    public static let all: [Person] = [you, ava, dad, kenji, luz, amara, mom, priya]
}
