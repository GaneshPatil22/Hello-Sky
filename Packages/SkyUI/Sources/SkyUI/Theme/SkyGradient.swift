import SwiftUI

/// The sky's colours at one sun elevation, from the top of the screen to the horizon.
public struct SkyGradient: Hashable, Sendable {
    public let top: SkyColor
    public let horizon: SkyColor

    public init(top: SkyColor, horizon: SkyColor) {
        self.top = top
        self.horizon = horizon
    }

    public func blended(towards other: SkyGradient, amount: Double) -> SkyGradient {
        SkyGradient(
            top: top.blended(towards: other.top, amount: amount),
            horizon: horizon.blended(towards: other.horizon, amount: amount)
        )
    }

    public var linearGradient: LinearGradient {
        LinearGradient(colors: [top.color, horizon.color], startPoint: .top, endPoint: .bottom)
    }
}
