import Foundation

/// How much of the sky is covered, as fractions from 0 to 1.
///
/// The layers are optional because not every source reports them. The renderer
/// uses them when they are there and falls back to `total` when they are not.
public struct CloudCover: Hashable, Sendable, Codable {
    public let total: Double
    public let low: Double?
    public let middle: Double?
    public let high: Double?

    public init(total: Double, low: Double? = nil, middle: Double? = nil, high: Double? = nil) {
        self.total = total.clampedToFraction
        self.low = low?.clampedToFraction
        self.middle = middle?.clampedToFraction
        self.high = high?.clampedToFraction
    }

    public static let clear = CloudCover(total: 0, low: 0, middle: 0, high: 0)
}

extension Double {
    /// Sources occasionally report slightly outside 0...1; the renderer must not see that.
    var clampedToFraction: Double {
        min(max(self, 0), 1)
    }
}
