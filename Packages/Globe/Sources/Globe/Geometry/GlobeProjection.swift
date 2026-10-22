import Foundation
import SkyCore
import simd

/// Turns places on the globe into points on the screen.
///
/// People markers are SwiftUI views laid over the scene rather than 3D
/// entities, which makes taps, labels and VoiceOver ordinary. That trade needs
/// this: the maths that says where a city has ended up, and whether it is
/// facing us at all.
public enum GlobeProjection {
    /// Where a place appears, or `nil` when it is round the back.
    public static func screenPoint(
        for coordinate: Coordinate,
        camera: GlobeCamera,
        size: CGSize
    ) -> CGPoint? {
        let rotated = rotate(GlobeGeometry.vector(for: coordinate), by: camera)
        guard Double(rotated.z) > Visibility.facingUsAbove else { return nil }

        let radius = Double(min(size.width, size.height)) * Layout.radiusFraction
        return CGPoint(
            x: size.width / 2 + Double(rotated.x) * radius,
            y: size.height / 2 - Double(rotated.y) * radius
        )
    }

    /// How fully a marker should show: solid face on, fading as it turns away.
    public static func visibility(for coordinate: Coordinate, camera: GlobeCamera) -> Double {
        let facing = Double(rotate(GlobeGeometry.vector(for: coordinate), by: camera).z)
        guard facing > Visibility.facingUsAbove else { return 0 }
        return ((facing - Visibility.facingUsAbove) / Visibility.fullyVisibleAbove).clamped(to: 0...1)
    }

    /// Points along the great circle between two places, for an arc.
    ///
    /// Interpolating the vectors and renormalising follows the sphere, which is
    /// what makes the arc look like a flight path rather than a straight line.
    public static func arc(
        from start: Coordinate,
        to end: Coordinate,
        camera: GlobeCamera,
        size: CGSize,
        steps: Int = Layout.arcSteps
    ) -> [CGPoint?] {
        let a = GlobeGeometry.vector(for: start)
        let b = GlobeGeometry.vector(for: end)
        return (0...steps).map { step in
            let t = Float(step) / Float(steps)
            let point = simd_normalize(simd_mix(a, b, SIMD3(repeating: t)))
            return screenPoint(for: GlobeGeometry.coordinate(for: point), camera: camera, size: size)
        }
    }

    /// The point on the near side of the sphere under a screen position, or
    /// `nil` when the position is off the globe.
    ///
    /// The inverse of `screenPoint`, which lets a test ask what is actually
    /// under a pixel rather than trusting the drawing code's own maths.
    public static func surfacePoint(
        at screenPoint: CGPoint,
        camera: GlobeCamera,
        centre: CGPoint,
        radius: Double
    ) -> SIMD3<Float>? {
        let x = (screenPoint.x - centre.x) / radius
        let y = -(screenPoint.y - centre.y) / radius
        let squared = x * x + y * y
        guard squared <= 1 else { return nil }

        let inView = SIMD3(Float(x), Float(y), Float((1 - squared).squareRoot()))
        return unrotate(inView, by: camera)
    }

    /// Applies the camera's turn to a point on the sphere.
    ///
    /// Public because arcs ride above the surface and so cannot go through
    /// `screenPoint`, which assumes a point is on it.
    public static func rotate(_ vector: SIMD3<Float>, by camera: GlobeCamera) -> SIMD3<Float> {
        let yaw = Float(-camera.longitude * .pi / 180)
        let pitch = Float(camera.latitude * .pi / 180)

        let afterYaw = SIMD3(
            vector.x * cos(yaw) + vector.z * sin(yaw),
            vector.y,
            -vector.x * sin(yaw) + vector.z * cos(yaw)
        )
        return SIMD3(
            afterYaw.x,
            afterYaw.y * cos(pitch) - afterYaw.z * sin(pitch),
            afterYaw.y * sin(pitch) + afterYaw.z * cos(pitch)
        )
    }

    /// Undoes `rotate`, turning a view-space direction back into the Earth's frame.
    static func unrotate(_ vector: SIMD3<Float>, by camera: GlobeCamera) -> SIMD3<Float> {
        let yaw = Float(-camera.longitude * .pi / 180)
        let pitch = Float(camera.latitude * .pi / 180)

        let beforePitch = SIMD3(
            vector.x,
            vector.y * cos(pitch) + vector.z * sin(pitch),
            -vector.y * sin(pitch) + vector.z * cos(pitch)
        )
        return SIMD3(
            beforePitch.x * cos(yaw) - beforePitch.z * sin(yaw),
            beforePitch.y,
            beforePitch.x * sin(yaw) + beforePitch.z * cos(yaw)
        )
    }
}

extension GlobeProjection {
    public enum Visibility {
        /// Just past the edge, so a marker disappears before it would smear.
        public static let facingUsAbove = 0.05
        /// How far past the edge a marker takes to reach full strength.
        public static let fullyVisibleAbove = 0.25
    }

    public enum Layout {
        /// The globe fills most of the shorter side.
        public static let radiusFraction = 0.40
        public static let arcSteps = 48
    }
}
