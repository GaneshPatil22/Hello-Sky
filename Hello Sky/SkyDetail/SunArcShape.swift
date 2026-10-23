import SwiftUI

/// The sun's path across the day, as an arc from one horizon to the other.
nonisolated struct SunArcShape: Shape {
    /// How much of the arc to draw, from 0 at sunrise to 1 at sunset.
    var portion: Double = 1

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = Layout.steps
        let last = max(Int(Double(steps) * min(max(portion, 0), 1)), 1)

        for step in 0...last {
            let t = Double(step) / Double(steps)
            let point = Self.point(at: t, in: rect)
            if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }

    /// Where the sun is along the arc, with 0 at sunrise and 1 at sunset.
    static func point(at t: Double, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * t,
            y: rect.maxY - rect.height * sin(.pi * min(max(t, 0), 1))
        )
    }

    private enum Layout {
        static let steps = 48
    }
}
