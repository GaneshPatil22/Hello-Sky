#if os(iOS)
import RealityKit
import SkyCore
import SwiftUI

/// The Earth itself: a lit sphere you can spin, with no chrome on it.
///
/// The camera is passed in rather than owned here, and changes are reported
/// back. During the move to someone's sky the parent supplies an interpolated
/// camera and ignores the reports, so the turn cannot be fought by inertia.
public struct GlobeSceneView: View {
    let camera: GlobeCamera
    let date: Date
    /// False while a transition is driving the camera.
    let isInteractive: Bool
    let onCameraChange: (GlobeCamera) -> Void

    @State private var dragOrigin: GlobeCamera?
    @State private var lastFrame: Date = .now
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        camera: GlobeCamera,
        date: Date,
        isInteractive: Bool = true,
        onCameraChange: @escaping (GlobeCamera) -> Void
    ) {
        self.camera = camera
        self.date = date
        self.isInteractive = isInteractive
        self.onCameraChange = onCameraChange
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: Motion.frameInterval,
                                paused: reduceMotion || !isInteractive)) { context in
            RealityView { content in
                content.add(makeGlobe())
            } update: { content in
                apply(to: content)
            }
            .onChange(of: context.date) { _, now in
                advance(to: now)
            }
        }
        .gesture(spin, isEnabled: isInteractive)
        .accessibilityLabel("Globe")
        .accessibilityHint("Drag to turn the Earth")
    }

    private var spin: some Gesture {
        DragGesture()
            .onChanged { value in
                let origin = dragOrigin ?? camera
                dragOrigin = origin
                var moved = origin
                moved.drag(by: (
                    longitude: -value.translation.width * Motion.degreesPerPoint,
                    latitude: value.translation.height * Motion.degreesPerPoint
                ))
                onCameraChange(moved)
            }
            .onEnded { value in
                dragOrigin = nil
                var released = camera
                released.release(velocity: -value.velocity.width * Motion.degreesPerPoint)
                onCameraChange(released)
            }
    }

    private func advance(to now: Date) {
        let elapsed = now.timeIntervalSince(lastFrame)
        lastFrame = now
        guard isInteractive, dragOrigin == nil else { return }
        var moved = camera
        moved.advance(by: min(elapsed, Motion.longestStep))
        onCameraChange(moved)
    }

    private func makeGlobe() -> Entity {
        let anchor = Entity()
        anchor.name = Scene.anchorName

        let sphere = ModelEntity(
            mesh: .generateSphere(radius: Scene.radius),
            materials: [material()]
        )
        sphere.name = Scene.globeName
        anchor.addChild(sphere)
        return anchor
    }

    private func material() -> any RealityKit.Material {
        // A plain material is the fallback if the custom one cannot be built;
        // the globe still turns and still shows, just without a terminator.
        (try? GlobeMaterial.dayNight(sunDirection: GlobeGeometry.sunDirection(at: date)))
            ?? UnlitMaterial(color: .darkGray)
    }

    private func apply(to content: some RealityViewContentProtocol) {
        guard let anchor = content.entities.first(where: { $0.name == Scene.anchorName }) else { return }
        anchor.transform.rotation = rotation

        guard let sphere = anchor.children.first(where: { $0.name == Scene.globeName }) as? ModelEntity,
              var material = sphere.model?.materials.first as? CustomMaterial else { return }
        GlobeMaterial.update(&material, sunDirection: GlobeGeometry.sunDirection(at: date))
        sphere.model?.materials = [material]
    }

    /// The camera's angles, applied to the globe rather than to a camera, so
    /// the overlay's projection and the scene use the same single source.
    private var rotation: simd_quatf {
        let yaw = simd_quatf(angle: Float(-camera.longitude * .pi / 180), axis: SIMD3(0, 1, 0))
        let pitch = simd_quatf(angle: Float(camera.latitude * .pi / 180), axis: SIMD3(1, 0, 0))
        return pitch * yaw
    }
}

extension GlobeSceneView {
    private enum Scene {
        static let radius: Float = 0.5
        static let globeName = "globe"
        static let anchorName = "globe-anchor"
    }

    private enum Motion {
        static let frameInterval = 1.0 / 60
        /// How far a drag turns the globe.
        static let degreesPerPoint = 0.35
        /// Caps the catch-up after the app has been away, so it never lurches.
        static let longestStep: TimeInterval = 1.0 / 20
    }
}
#endif
