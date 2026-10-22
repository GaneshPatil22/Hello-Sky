import Foundation
import SkyCore
import simd

/// Everything the globe needs to draw one frame, worked out once per render.
///
/// Pure values, so where the terminator falls and which dots are lit can be
/// tested without drawing anything.
public struct GlobeFrame: Sendable {
    /// The sun as a direction, in the Earth's own frame.
    public let sun: SIMD3<Float>
    /// The same direction after the camera's turn, which is where it sits on screen.
    public let sunInView: SIMD3<Float>
    public let camera: GlobeCamera
    public let centre: CGPoint
    public let radius: Double

    public init(camera: GlobeCamera, date: Date, size: CGSize) {
        self.camera = camera
        self.sun = GlobeGeometry.sunDirection(at: date)
        self.sunInView = GlobeProjection.rotate(sun, by: camera)
        self.centre = CGPoint(x: size.width / 2, y: size.height / 2)
        self.radius = min(size.width, size.height) * GlobeProjection.Layout.radiusFraction
    }

    /// How lit a point on the Earth is, from -1 at midnight to 1 at noon.
    ///
    /// Taken in the Earth's own frame, not the view's. That is what keeps the
    /// daylight on a city fixed while the globe is spun: turning the view must
    /// not change what time it is anywhere.
    public func light(at point: SIMD3<Float>) -> Double {
        Double(simd_dot(point, sun))
    }

    /// Where a point on the sphere lands on screen, and how far it faces us.
    public func project(_ point: SIMD3<Float>) -> (position: CGPoint, facing: Double) {
        let rotated = GlobeProjection.rotate(point, by: camera)
        return (
            CGPoint(x: centre.x + Double(rotated.x) * radius, y: centre.y - Double(rotated.y) * radius),
            Double(rotated.z)
        )
    }
}
