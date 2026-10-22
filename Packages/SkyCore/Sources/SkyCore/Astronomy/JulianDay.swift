import Foundation

/// The Julian day number, the continuous day count astronomy formulae are written against.
public struct JulianDay: Hashable, Sendable, Comparable {
    public let value: Double

    public init(_ value: Double) {
        self.value = value
    }

    public init(_ date: Date) {
        self.init(date.timeIntervalSince1970 / Constants.secondsPerDay + Constants.unixEpoch)
    }

    /// Days since the J2000.0 epoch, which is what the solar and lunar series use.
    public var daysSinceJ2000: Double {
        value - Constants.j2000
    }

    public static func < (lhs: JulianDay, rhs: JulianDay) -> Bool {
        lhs.value < rhs.value
    }
}

extension JulianDay {
    enum Constants {
        static let secondsPerDay = 86_400.0
        /// The Julian day of 1970-01-01T00:00:00Z.
        static let unixEpoch = 2_440_587.5
        /// The Julian day of 2000-01-01T12:00:00Z.
        static let j2000 = 2_451_545.0
    }
}
