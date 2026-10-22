import Foundation
import SkyCore
import simd

/// A flight path between two places: a great circle, lifted off the surface.
///
/// Lifted because an arc drawn on the sphere reads as a line painted on the
/// Earth, where one raised above it reads as a journey. The rise is largest in
/// the middle and grows with distance, the way a flight path does.
public struct GlobeArc: Sendable {
    public let points: [SIMD3<Float>]
    /// Roughly how long the arc is, used to pace a dot travelling along it.
    public let length: Double

    public init(from start: Coordinate, to end: Coordinate, steps: Int = Layout.steps) {
        let a = GlobeGeometry.vector(for: start)
        let b = GlobeGeometry.vector(for: end)
        let separation = Double(acos(simd_dot(a, b).clamped(to: -1...1)))

        guard separation > Layout.shortestArc else {
            self.points = [a, b]
            self.length = 0
            return
        }

        let rise = Layout.maximumRise * pow(separation / .pi, Layout.riseFalloff)
        self.points = (0...steps).map { step in
            let t = Double(step) / Double(steps)
            // Spherical interpolation keeps the path on the great circle; the
            // lift then pushes it outward, most of all at the midpoint.
            let first = Float(sin((1 - t) * separation) / sin(separation))
            let second = Float(sin(t * separation) / sin(separation))
            let onSphere = a * first + b * second
            return onSphere * Float(1 + rise * sin(.pi * t))
        }
        self.length = separation
    }
}

extension GlobeArc {
    public enum Layout {
        public static let steps = 72
        /// How far the midpoint rises, as a fraction of the Earth's radius.
        public static let maximumRise = 0.11
        /// Short hops rise less than long ones, but not proportionally less.
        public static let riseFalloff = 0.8
        public static let shortestArc = 0.001
    }
}

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
