import Foundation

/// Whether now is a good moment to contact someone.
public enum CallStatus: String, Hashable, Sendable, CaseIterable {
    /// Comfortably inside their waking hours.
    case good
    /// Close to the edge of their day: just waking, or getting late.
    case maybe
    /// Outside their waking hours.
    case sleeping

    /// The reading for `person` at `date`.
    ///
    /// Returns `.sleeping` if the person's time zone cannot be resolved, which
    /// is the safe answer: it never suggests calling someone in the night.
    public static func status(for person: Person, at date: Date) -> CallStatus {
        guard let timeZone = person.place.timeZone else { return .sleeping }
        return status(
            localHour: LocalTime.hour(at: date, in: timeZone),
            awakeHours: person.awakeHours
        )
    }

    static func status(localHour: Double, awakeHours: AwakeHours) -> CallStatus {
        let comfortable = (awakeHours.start + Margins.settled)..<(awakeHours.end - Margins.settled)
        if comfortable.contains(localHour) { return .good }

        let edge = (awakeHours.start - Margins.edge)..<(awakeHours.end + Margins.edge)
        return edge.contains(localHour) ? .maybe : .sleeping
    }
}

extension CallStatus {
    /// How far inside and outside the waking window the bands reach, in hours.
    public enum Margins {
        /// Ignore the first and last half hour awake, when someone is barely up or winding down.
        public static let settled = 0.5
        /// An hour either side of the window still counts as a maybe.
        public static let edge = 1.0
    }
}
