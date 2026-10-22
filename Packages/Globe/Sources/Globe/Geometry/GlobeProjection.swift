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

    /// Applies the camera's turn to a point on the sphere.
    static func rotate(_ vector: SIMD3<Float>, by camera: GlobeCamera) -> SIMD3<Float> {
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
        public static let radiusFraction = 0.42
        public static let arcSteps = 48
    }
}
