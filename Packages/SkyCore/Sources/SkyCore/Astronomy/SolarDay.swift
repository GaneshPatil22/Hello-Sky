import Foundation

/// The sun's comings and goings around one moment at one place.
///
/// Both events are optional because they genuinely do not exist inside the
/// polar circles for part of the year. Callers must handle that rather than
/// assume a sunrise is always coming.
public struct SolarDay: Hashable, Sendable {
    /// Whether the sun is currently above the horizon.
    public let isDaylight: Bool
    /// The next sunrise or sunset, or `nil` during midnight sun or polar night.
    public let next: SolarEvent?
    /// The most recent sunrise or sunset, or `nil` during midnight sun or polar night.
    public let previous: SolarEvent?

    /// Set when the sun neither rises nor sets within the search span.
    public var polarCondition: PolarCondition? {
        guard next == nil, previous == nil else { return nil }
        return isDaylight ? .midnightSun : .polarNight
    }
}

/// What it means when a day has no sunrise and no sunset.
public enum PolarCondition: String, Hashable, Sendable {
    /// The sun stays up.
    case midnightSun
    /// The sun stays down.
    case polarNight
}
