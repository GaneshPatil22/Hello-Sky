import Foundation

/// One entry in a look's sky table: the colours to use when the sun sits at `elevation`.
public struct SkyKeyframe: Hashable, Sendable {
    /// Sun elevation in degrees, negative below the horizon.
    public let elevation: Double
    public let gradient: SkyGradient

    public init(elevation: Double, gradient: SkyGradient) {
        self.elevation = elevation
        self.gradient = gradient
    }
}
