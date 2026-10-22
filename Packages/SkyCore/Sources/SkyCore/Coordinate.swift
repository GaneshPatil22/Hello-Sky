import Foundation

/// A point on Earth, in degrees.
///
/// Latitude runs from -90 at the south pole to +90 at the north pole; longitude
/// runs from -180 to +180, increasing eastward.
public struct Coordinate: Hashable, Sendable, Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Coordinate {
    public enum Limits {
        public static let latitudeRange: ClosedRange<Double> = -90...90
        public static let longitudeRange: ClosedRange<Double> = -180...180
    }

    /// Whether both components fall inside the valid range for their axis.
    public var isValid: Bool {
        Limits.latitudeRange.contains(latitude) && Limits.longitudeRange.contains(longitude)
    }
}
