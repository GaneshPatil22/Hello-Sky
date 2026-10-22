import Foundation

/// A look's whole sky, as a table of keyframes read by sun elevation.
///
/// Elevations outside the table clamp to its ends, so a palette is total: every
/// elevation yields a gradient.
public struct SkyPalette: Hashable, Sendable {
    public let keyframes: [SkyKeyframe]

    /// Keyframes are sorted on creation, so look files may list them in any order.
    public init(keyframes: [SkyKeyframe]) {
        self.keyframes = keyframes.sorted { $0.elevation < $1.elevation }
    }

    public func gradient(forSunElevation elevation: Double) -> SkyGradient {
        guard let first = keyframes.first, let last = keyframes.last else {
            return Fallback.gradient
        }
        if elevation <= first.elevation { return first.gradient }
        if elevation >= last.elevation { return last.gradient }

        for (lower, upper) in zip(keyframes, keyframes.dropFirst()) where elevation <= upper.elevation {
            let span = upper.elevation - lower.elevation
            guard span > 0 else { return upper.gradient }
            let amount = (elevation - lower.elevation) / span
            return lower.gradient.blended(towards: upper.gradient, amount: amount)
        }
        return last.gradient
    }
}

extension SkyPalette {
    /// Used only when a look ships an empty table, which the registry test rejects.
    enum Fallback {
        static let gradient = SkyGradient(
            top: SkyColor(hex: 0x000000),
            horizon: SkyColor(hex: 0x000000)
        )
    }

    /// The sun elevations the looks key their colours to.
    ///
    /// The twilight values are the standard astronomical definitions; the rest
    /// are chosen so colour changes fastest around the horizon, where the eye
    /// notices it most.
    public enum Elevation {
        public static let deepNight = -90.0
        public static let astronomicalTwilight = -18.0
        public static let nauticalTwilight = -12.0
        public static let civilTwilight = -6.0
        public static let blueHour = -2.0
        public static let sunrise = 0.5
        public static let goldenHour = 6.0
        public static let morning = 14.0
        public static let midMorning = 30.0
        public static let zenith = 90.0
    }
}
