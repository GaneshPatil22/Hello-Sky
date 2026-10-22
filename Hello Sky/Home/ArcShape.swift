import SwiftUI

/// A path through the projected arc points, broken wherever the line goes
/// round the back of the globe.
///
/// `nonisolated` because SwiftUI evaluates a shape's path off the main actor;
/// the app target defaults to `MainActor` isolation, which would otherwise make
/// this conformance a data race.
nonisolated struct ArcShape: Shape {
    let points: [CGPoint?]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var isDrawing = false

        for point in points {
            guard let point else {
                isDrawing = false
                continue
            }
            if isDrawing {
                path.addLine(to: point)
            } else {
                path.move(to: point)
                isDrawing = true
            }
        }
        return path
    }
}
