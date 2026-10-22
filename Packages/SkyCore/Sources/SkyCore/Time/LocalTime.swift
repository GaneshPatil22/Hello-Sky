import Foundation

/// Reading a wall clock in another time zone.
///
/// Everything goes through `TimeZone`, so half-hour and 45-minute offsets and
/// daylight saving are handled by the system rather than by arithmetic here.
public enum LocalTime {
    /// The local hour as a fraction, so 7.5 is half past seven.
    public static func hour(at date: Date, in timeZone: TimeZone) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.hour, .minute, .second], from: date)
        let hour = Double(parts.hour ?? 0)
        let minute = Double(parts.minute ?? 0) / Constants.minutesPerHour
        let second = Double(parts.second ?? 0) / Constants.secondsPerHour
        return hour + minute + second
    }

    /// The offset between two zones at a moment, in hours. Positive means `other` is ahead.
    ///
    /// Taken at `date` rather than from the zones' raw offsets, so the two
    /// sides of a daylight-saving change give different answers, which is correct.
    public static func offset(at date: Date, from base: TimeZone, to other: TimeZone) -> Double {
        let difference = other.secondsFromGMT(for: date) - base.secondsFromGMT(for: date)
        return Double(difference) / Constants.secondsPerHour
    }

    /// How `other`'s calendar day compares with `base`'s at the same moment.
    public static func relativeDay(at date: Date, in other: TimeZone, comparedTo base: TimeZone) -> RelativeDay {
        let otherDay = calendarDay(at: date, in: other)
        let baseDay = calendarDay(at: date, in: base)
        if otherDay == baseDay { return .sameDay }
        return otherDay > baseDay ? .tomorrow : .yesterday
    }

    /// The local calendar date as comparable parts.
    private static func calendarDay(at date: Date, in timeZone: TimeZone) -> SortableDay {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return SortableDay(year: parts.year ?? 0, month: parts.month ?? 0, day: parts.day ?? 0)
    }

    private struct SortableDay: Hashable, Comparable {
        let year: Int
        let month: Int
        let day: Int

        static func < (lhs: SortableDay, rhs: SortableDay) -> Bool {
            (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
        }
    }
}

extension LocalTime {
    enum Constants {
        static let minutesPerHour = 60.0
        static let secondsPerHour = 3_600.0
    }
}

/// Whether somewhere else is on the same calendar day as you.
public enum RelativeDay: String, Hashable, Sendable {
    case yesterday
    case sameDay
    case tomorrow
}
