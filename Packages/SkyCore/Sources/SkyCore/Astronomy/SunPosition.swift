import Foundation

/// Where the sun is from one place at one moment.
public struct SunPosition: Hashable, Sendable {
    /// Degrees above the horizon; negative when the sun has set.
    public let elevation: Double
    /// Degrees clockwise from true north: 90 is east, 180 south, 270 west.
    public let azimuth: Double
    /// Degrees west of the observer's meridian, within `-180..<180`. Zero at solar noon.
    public let hourAngle: Double
}

extension SunPosition {
    /// The light the sky is in at this elevation.
    public var phase: SolarPhase {
        SolarPhase(sunElevation: elevation)
    }

    /// Whether the sun is up, accounting for refraction and the sun's own width.
    public var isDaylight: Bool {
        elevation > Sun.horizonElevation
    }
}
