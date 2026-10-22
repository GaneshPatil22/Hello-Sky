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

    public var isVisible: Bool {
        elevation > 0
    }
}
