import SkyCore
import SwiftUI

/// The ring pulsing out from a marker, coloured by how reachable someone is.
///
/// Carries the status that the arcs deliberately do not, and it is only ever a
/// repeat of what the label already says, so nothing depends on seeing it.
struct StatusRipple: View {
    let status: CallStatus
    let diameter: Double
    /// Supplied by the globe's timeline rather than kept here, so six markers
    /// do not run six separate clocks.
    let now: Date

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // A still ring says the same thing without the movement.
            Circle()
                .stroke(StatusDot.colour(for: status).opacity(Layout.restingOpacity),
                        lineWidth: Layout.width)
                .frame(width: diameter * Layout.restingScale, height: diameter * Layout.restingScale)
        } else {
            let phase = Self.phase(at: now, status: status)
            Circle()
                .stroke(StatusDot.colour(for: status).opacity((1 - phase) * Layout.peakOpacity),
                        lineWidth: Layout.width)
                .frame(
                    width: diameter * (1 + phase * Layout.growth),
                    height: diameter * (1 + phase * Layout.growth)
                )
        }
    }

    /// Where the ring is in its cycle, from 0 just emitted to 1 faded out.
    ///
    /// A good time pulses quickest, asleep slowest, so the globe reads at a
    /// glance before any of the labels are.
    static func phase(at date: Date, status: CallStatus) -> Double {
        let period = Self.period(for: status)
        let elapsed = date.timeIntervalSinceReferenceDate
        return (elapsed.truncatingRemainder(dividingBy: period)) / period
    }

    static func period(for status: CallStatus) -> Double {
        switch status {
        case .good: 2.0
        case .maybe: 3.2
        case .sleeping: 4.6
        }
    }
}

extension StatusRipple {
    private enum Layout {
        static let growth = 0.85
        static let peakOpacity = 0.75
        static let width: Double = 1.6
        static let restingOpacity = 0.5
        static let restingScale = 1.35
    }
}
