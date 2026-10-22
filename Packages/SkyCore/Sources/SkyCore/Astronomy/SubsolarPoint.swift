import Foundation

/// The point on Earth with the sun directly overhead.
///
/// Its latitude is the solar declination and its longitude follows the sun
/// westward, so it is the single value every other sun calculation hangs off:
/// a place's hour angle is just its longitude minus this one.
public struct SubsolarPoint: Hashable, Sendable {
    /// Solar declination, in degrees.
    public let declination: Double
    /// Longitude of the sun's zenith, in degrees, within `-180..<180`.
    public let longitude: Double

    public var coordinate: Coordinate {
        Coordinate(latitude: declination, longitude: longitude)
    }
}
