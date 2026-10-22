import Foundation

extension Sun {
    /// Finds the sunrise or sunset either side of `date` at `coordinate`.
    ///
    /// The horizon crossing has no closed form in this model, so it is found by
    /// scanning in coarse steps for a change of state and then bisecting that
    /// bracket. Inside the polar circles there may be no crossing at all, and
    /// the search simply reports none rather than running forever.
    public static func solarDay(around date: Date, at coordinate: Coordinate) -> SolarDay {
        let isDaylightNow = position(at: date, from: coordinate).isDaylight
        return SolarDay(
            isDaylight: isDaylightNow,
            next: crossing(from: date, at: coordinate, searchingForward: true, startedInDaylight: isDaylightNow),
            previous: crossing(from: date, at: coordinate, searchingForward: false, startedInDaylight: isDaylightNow)
        )
    }

    private static func crossing(
        from date: Date,
        at coordinate: Coordinate,
        searchingForward: Bool,
        startedInDaylight: Bool
    ) -> SolarEvent? {
        let direction: Double = searchingForward ? 1 : -1
        var bracketStart = date
        var elapsed = Search.step

        while elapsed <= Search.span {
            let candidate = date.addingTimeInterval(direction * elapsed)
            let isDaylightThen = position(at: candidate, from: coordinate).isDaylight

            if isDaylightThen != startedInDaylight {
                let earlier = searchingForward ? bracketStart : candidate
                let later = searchingForward ? candidate : bracketStart
                let moment = refine(between: earlier, and: later, at: coordinate)
                // Walking forward, the sun's state after the crossing names the
                // event; walking back, the state before it does.
                let becomesDaylight = searchingForward ? isDaylightThen : startedInDaylight
                return SolarEvent(kind: becomesDaylight ? .sunrise : .sunset, date: moment)
            }

            bracketStart = candidate
            elapsed += Search.step
        }
        return nil
    }

    /// Bisects a bracket known to contain one crossing.
    private static func refine(between earlier: Date, and later: Date, at coordinate: Coordinate) -> Date {
        var low = earlier
        var high = later
        let lowIsDaylight = position(at: low, from: coordinate).isDaylight

        for _ in 0..<Search.refinements {
            let middle = Date(timeIntervalSince1970: (low.timeIntervalSince1970 + high.timeIntervalSince1970) / 2)
            if position(at: middle, from: coordinate).isDaylight == lowIsDaylight {
                low = middle
            } else {
                high = middle
            }
        }
        return Date(timeIntervalSince1970: (low.timeIntervalSince1970 + high.timeIntervalSince1970) / 2)
    }
}

extension Sun {
    enum Search {
        /// Coarse scan step. Small enough that no polar-latitude day is missed
        /// between two samples, large enough to keep the scan cheap.
        static let step: TimeInterval = 5 * 60
        /// How far either side of the moment to look before declaring polar day or night.
        /// Beyond 24 hours so a crossing is never missed by being just out of range.
        static let span: TimeInterval = 30 * 60 * 60
        /// Halvings of the bracket. 14 takes a 5-minute span below 0.02 seconds.
        static let refinements = 14
    }
}
