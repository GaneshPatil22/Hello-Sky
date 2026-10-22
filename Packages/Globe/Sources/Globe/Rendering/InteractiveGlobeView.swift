import SkyCore
import SwiftUI

/// The drawn globe, with dragging, inertia and the idle drift attached.
public struct InteractiveGlobeView: View {
    let camera: GlobeCamera
    let date: Date
    let quality: GlobeQuality
    /// False while a transition is driving the camera.
    let isInteractive: Bool
    let onCameraChange: (GlobeCamera) -> Void

    @State private var dragOrigin: GlobeCamera?
    @State private var lastFrame: Date = .now
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        camera: GlobeCamera,
        date: Date,
        quality: GlobeQuality = .high,
        isInteractive: Bool = true,
        onCameraChange: @escaping (GlobeCamera) -> Void
    ) {
        self.camera = camera
        self.date = date
        self.quality = quality
        self.isInteractive = isInteractive
        self.onCameraChange = onCameraChange
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: Motion.frameInterval,
                                paused: reduceMotion || !isInteractive)) { context in
            GlobeCanvasView(camera: camera, date: date, quality: quality)
                .onChange(of: context.date) { _, now in
                    advance(to: now)
                }
        }
        .gesture(spin, isEnabled: isInteractive)
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
}

extension InteractiveGlobeView {
    private enum Motion {
        static let frameInterval = 1.0 / 60
        static let degreesPerPoint = 0.35
        /// Caps the catch-up after the app has been away, so it never lurches.
        static let longestStep: TimeInterval = 1.0 / 20
    }
}
