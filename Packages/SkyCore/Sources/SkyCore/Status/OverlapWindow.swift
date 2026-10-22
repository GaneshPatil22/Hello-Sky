import Foundation

/// A stretch of time when two people are both awake.
public struct OverlapWindow: Hashable, Sendable {
    public let start: Date
    public let end: Date

    public var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    /// Length in hours, which is how the window is described to the user.
    public var hours: Double {
        duration / Constants.secondsPerHour
    }
}

extension OverlapWindow {
    enum Constants {
        static let secondsPerHour = 3_600.0
    }
}
