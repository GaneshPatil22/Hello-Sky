import Foundation

/// The named light a sky is in, used for labels and for choosing sky colours.
public enum SolarPhase: String, Hashable, Sendable, CaseIterable {
    case day
    case goldenHour
    case blueHour
    case night

    public init(sunElevation elevation: Double) {
        switch elevation {
        case Thresholds.day...: self = .day
        case Thresholds.goldenHour...: self = .goldenHour
        case Thresholds.blueHour...: self = .blueHour
        default: self = .night
        }
    }
}

extension SolarPhase {
    /// Elevations in degrees at which one phase becomes the next.
    ///
    /// `blueHour` is civil twilight, the standard definition. The other two are
    /// the prototype's thresholds, chosen by eye rather than by convention.
    public enum Thresholds {
        public static let day = 10.0
        public static let goldenHour = 0.0
        public static let blueHour = -6.0
    }
}
