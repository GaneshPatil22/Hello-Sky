import SkyCore
import SwiftUI

/// One sky, drawn from a snapshot.
///
/// Takes a finished `SkySnapshot` and a motion value rather than a date, so the
/// same view renders a live sky, a still frame for Reduce Motion, and a
/// snapshot test, with no branch inside it.
public struct SkyView: View {
    let snapshot: SkySnapshot
    /// Seconds of elapsed drift. Zero renders a still frame.
    let motion: Double

    public init(snapshot: SkySnapshot, motion: Double = 0) {
        self.snapshot = snapshot
        self.motion = motion
    }

    public var body: some View {
        ZStack {
            SkyBackground(snapshot: snapshot)
            SunGlowLayer(snapshot: snapshot)
            Canvas(opaque: false) { context, size in
                var context = context
                StarsLayer(snapshot: snapshot).draw(in: &context, size: size, motion: motion)
                MoonLayer(snapshot: snapshot).draw(in: &context, size: size)
                CloudsLayer(snapshot: snapshot).draw(in: &context, size: size, motion: motion)
                RainLayer(snapshot: snapshot).draw(in: &context, size: size, motion: motion)
                HillsLayer(snapshot: snapshot).draw(in: &context, size: size)
            }
        }
        .background(snapshot.gradient.horizon.color)
        .accessibilityElement()
        .accessibilityLabel(Text(accessibilityDescription))
    }

    /// The sky in words, for anyone who cannot see it.
    private var accessibilityDescription: String {
        let phase = switch snapshot.solarPhase {
        case .day: "Daytime"
        case .goldenHour: "Golden hour"
        case .blueHour: "Blue hour"
        case .night: "Night"
        }
        let cover = switch snapshot.cloudCover.total {
        case ..<0.2: "clear"
        case ..<0.6: "some cloud"
        default: "cloudy"
        }
        return snapshot.rain > 0.1 ? "\(phase), \(cover), raining" : "\(phase), \(cover)"
    }
}
