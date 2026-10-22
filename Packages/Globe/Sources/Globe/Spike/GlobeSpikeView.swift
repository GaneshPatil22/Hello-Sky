#if os(iOS)
import RealityKit
import SkyCore
import SwiftUI

/// The spike, kept as a runnable proof rather than thrown away.
///
/// A textured-free sphere lit by the real subsolar point. If this renders on
/// device, the day/night shader approach is sound and Phase 5 can build on it.
public struct GlobeSpikeView: View {
    @State private var date: Date
    @State private var failure: String?

    public init(date: Date = .now) {
        _date = State(wrappedValue: date)
    }

    public var body: some View {
        Group {
            if let failure {
                ContentUnavailableView(
                    "Custom material unavailable",
                    systemImage: "cube.transparent",
                    description: Text(failure)
                )
            } else {
                RealityView { content in
                    do {
                        content.add(try makeGlobe())
                    } catch {
                        failure = "\(error)"
                    }
                } update: { content in
                    updateSun(in: content)
                }
                .realityViewCameraControls(.orbit)
            }
        }
        .overlay(alignment: .bottom) { timeSlider }
    }

    private var timeSlider: some View {
        VStack {
            Text(date, format: .dateTime.hour().minute().day().month())
                .font(.caption.monospacedDigit())
            Slider(
                value: Binding(
                    get: { date.timeIntervalSince1970 },
                    set: { date = Date(timeIntervalSince1970: $0) }
                ),
                in: Self.sliderRange
            )
        }
        .padding()
        .background(.bar)
    }

    private func makeGlobe() throws -> Entity {
        let sphere = ModelEntity(
            mesh: .generateSphere(radius: Layout.radius),
            materials: [try GlobeMaterial.dayNight(sunDirection: GlobeGeometry.sunDirection(at: date))]
        )
        sphere.name = Layout.globeName
        return sphere
    }

    // The concrete type differs by platform (`RealityViewCameraContent` on
    // iOS), so the protocol is what keeps this spelling portable.
    private func updateSun(in content: some RealityViewContentProtocol) {
        guard let globe = content.entities.first(where: { $0.name == Layout.globeName }) as? ModelEntity,
              var material = globe.model?.materials.first as? CustomMaterial else { return }
        GlobeMaterial.update(&material, sunDirection: GlobeGeometry.sunDirection(at: date))
        globe.model?.materials = [material]
    }

    private static let sliderRange: ClosedRange<Double> = {
        let now = Date.now.timeIntervalSince1970
        return (now - 12 * 3_600)...(now + 36 * 3_600)
    }()
}

extension GlobeSpikeView {
    private enum Layout {
        static let radius: Float = 0.5
        static let globeName = "globe"
    }
}
#endif
