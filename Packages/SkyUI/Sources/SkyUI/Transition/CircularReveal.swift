import SwiftUI

/// Opens a view through a circle growing from a point.
///
/// The circle starts where the city is on the globe and grows past the far
/// corner, so the sky appears to come from that place rather than over it.
public struct CircularReveal: ViewModifier, Animatable {
    public var progress: Double
    public let origin: CGPoint
    /// False for Reduce Motion, which gets a crossfade instead.
    public let isEnabled: Bool

    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    public init(progress: Double, origin: CGPoint, isEnabled: Bool = true) {
        self.progress = progress
        self.origin = origin
        self.isEnabled = isEnabled
    }

    public func body(content: Content) -> some View {
        if isEnabled {
            content.mask { circle }
        } else {
            content.opacity(progress)
        }
    }

    private var circle: some View {
        GeometryReader { proxy in
            let diameter = Self.coveringDiameter(from: origin, in: proxy.size) * progress
            Circle()
                .frame(width: diameter, height: diameter)
                .position(origin)
        }
    }

    /// Large enough to reach the furthest corner from the origin, so the reveal
    /// never leaves an unfilled sliver.
    static func coveringDiameter(from origin: CGPoint, in size: CGSize) -> Double {
        let corners = [
            CGPoint(x: 0, y: 0), CGPoint(x: size.width, y: 0),
            CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height),
        ]
        let furthest = corners.map { hypot($0.x - origin.x, $0.y - origin.y) }.max() ?? 0
        return furthest * 2
    }
}
