import Foundation

/// The window a person is usually awake, in their own local hours.
///
/// Hours are fractional, so 7.5 means half past seven. The window does not wrap
/// past midnight in v1, matching the demo's model.
public struct AwakeHours: Hashable, Sendable, Codable {
    public let start: Double
    public let end: Double

    public init(start: Double, end: Double) {
        self.start = start
        self.end = end
    }

    public static let `default` = AwakeHours(start: 8, end: 23)
}

extension AwakeHours {
    public enum Limits {
        public static let hourRange: ClosedRange<Double> = 0...24
    }

    public var isValid: Bool {
        Limits.hourRange.contains(start) && Limits.hourRange.contains(end) && start < end
    }

    public var duration: Double { end - start }

    /// Whether `localHour` falls inside the window.
    public func contains(localHour: Double) -> Bool {
        localHour >= start && localHour < end
    }
}
