import Foundation
import SkyCore

/// Where the globe is turned to, and how it keeps turning.
///
/// A plain value with no RealityKit in it, so dragging, inertia and the slow
/// idle spin can be tested without rendering anything.
public struct GlobeCamera: Hashable, Sendable {
    /// Degrees turned about the pole. Increasing spins the globe eastward.
    public private(set) var longitude: Double
    /// Degrees tilted, clamped so the globe never flips over.
    public private(set) var latitude: Double
    /// Degrees a second still being carried from the last drag.
    public private(set) var spin: Double

    public init(longitude: Double = 0, latitude: Double = 0, spin: Double = 0) {
        self.longitude = Self.wrapped(longitude)
        self.latitude = latitude.clamped(to: Limits.latitude)
        self.spin = spin
    }

    /// Applies a drag, in degrees.
    public mutating func drag(by delta: (longitude: Double, latitude: Double)) {
        longitude = Self.wrapped(longitude + delta.longitude)
        latitude = (latitude + delta.latitude).clamped(to: Limits.latitude)
        spin = 0
    }

    /// Hands the globe its momentum when a drag ends.
    public mutating func release(velocity degreesPerSecond: Double) {
        spin = degreesPerSecond.clamped(to: Limits.spin)
    }

    /// Moves time forward: carried momentum decays, and the idle drift takes over.
    public mutating func advance(by seconds: TimeInterval) {
        guard seconds > 0 else { return }
        longitude = Self.wrapped(longitude + spin * seconds + Motion.idleDrift * seconds)
        // Exponential decay, so the globe slows the way a heavy thing does
        // rather than stopping on a fixed count of frames.
        spin *= pow(Motion.decayPerSecond, seconds)
        if abs(spin) < Motion.restsBelow { spin = 0 }
    }

    public var isCoasting: Bool { spin != 0 }

    static func wrapped(_ degrees: Double) -> Double {
        let turn = degrees.truncatingRemainder(dividingBy: 360)
        return turn < 0 ? turn + 360 : turn
    }
}

extension GlobeCamera {
    public enum Limits {
        /// Stops short of the poles, where a globe loses its sense of up.
        public static let latitude: ClosedRange<Double> = -80...80
        public static let spin: ClosedRange<Double> = -240...240
    }

    public enum Motion {
        /// The slow turn when nobody is touching it.
        public static let idleDrift = 1.5
        /// Fraction of momentum left after one second.
        public static let decayPerSecond = 0.12
        /// Below this the globe is treated as still.
        public static let restsBelow = 0.5
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension GlobeCamera {
    /// The angles that bring `coordinate` to the middle of the screen.
    ///
    /// Turning the globe so a point faces us is exactly undoing the projection:
    /// the camera's longitude and latitude become the place's own.
    public static func focused(on coordinate: Coordinate) -> GlobeCamera {
        GlobeCamera(longitude: coordinate.longitude, latitude: coordinate.latitude)
    }

    /// A camera part way between this one and `target`.
    ///
    /// Longitude takes the short way round, so a globe turning from 350° to 10°
    /// moves twenty degrees forward rather than three hundred and forty back.
    public func interpolated(towards target: GlobeCamera, progress: Double) -> GlobeCamera {
        let amount = progress.clamped(to: 0...1)
        let eased = amount * amount * (3 - 2 * amount)

        var difference = target.longitude - longitude
        if difference > 180 { difference -= 360 }
        if difference < -180 { difference += 360 }

        return GlobeCamera(
            longitude: longitude + difference * eased,
            latitude: latitude + (target.latitude - latitude) * eased,
            spin: 0
        )
    }
}
