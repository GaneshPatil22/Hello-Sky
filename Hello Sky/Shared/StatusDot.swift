import SkyCore
import SwiftUI

/// The small coloured dot beside a status, with the word that goes with it.
///
/// Always paired with text: colour alone would fail anyone who cannot
/// distinguish it, and the demo's green/amber/violet are close in brightness.
struct StatusDot: View {
    let status: CallStatus

    var body: some View {
        Circle()
            .fill(Self.colour(for: status))
            .frame(width: Layout.size, height: Layout.size)
            .accessibilityHidden(true)
    }

    static func colour(for status: CallStatus) -> Color {
        switch status {
        case .good: Palette.good
        case .maybe: Palette.maybe
        case .sleeping: Palette.sleeping
        }
    }

    static func label(for status: CallStatus) -> String {
        switch status {
        case .good: "Good time"
        case .maybe: "Getting late"
        case .sleeping: "Asleep"
        }
    }

    static func sentence(for status: CallStatus) -> String {
        switch status {
        case .good: "Good time to call"
        case .maybe: "Maybe not the moment"
        case .sleeping: "Asleep right now"
        }
    }
}

extension StatusDot {
    private enum Layout {
        static let size: Double = 7
    }

    /// Taken from the prototype's status colours, which read well on a sky.
    enum Palette {
        static let good = Color(red: 0.384, green: 0.961, blue: 0.639)
        static let maybe = Color(red: 1.0, green: 0.784, blue: 0.341)
        static let sleeping = Color(red: 0.549, green: 0.573, blue: 1.0)
    }
}
