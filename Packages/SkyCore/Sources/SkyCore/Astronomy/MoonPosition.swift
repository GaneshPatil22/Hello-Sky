import Foundation

/// Roughly where the moon is in the sky.
///
/// This uses a mean-motion approximation, not a full lunar theory: good enough
/// to put the moon in the right part of the sky and tilt it plausibly, and not
/// good enough for anything that needs real accuracy.
public struct MoonPosition: Hashable, Sendable {
    /// Degrees above the horizon; negative when the moon has set.
    public let elevation: Double
    /// Degrees clockwise from true north.
    public let azimuth: Double
    /// Degrees west of the observer's meridian, within `-180..<180`.
    ///
    /// Unlike azimuth, this advances evenly with the clock at every latitude,
    /// which is what makes it the right thing to place a drawing by.
    public let hourAngle: Double

    public var isVisible: Bool {
        elevation > 0
    }
}
