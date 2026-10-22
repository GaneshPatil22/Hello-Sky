import Foundation

/// Finding when two people are awake at the same time.
public enum Overlap {
    /// The longest stretch in the next day when both people are awake.
    ///
    /// Returns `nil` when there is no shared stretch long enough to be worth
    /// offering, which is common for places about twelve hours apart.
    public static func bestWindow(between one: Person, and other: Person, from date: Date) -> OverlapWindow? {
        let oneAwake = awakeSlots(for: one, from: date)
        let otherAwake = awakeSlots(for: other, from: date)
        let shared = zip(oneAwake, otherAwake).map { $0 && $1 }

        guard let longest = longestRun(in: shared), longest.count >= Resolution.minimumSlots else {
            return nil
        }
        return OverlapWindow(
            start: date.addingTimeInterval(Double(longest.lowerBound) * Resolution.slot),
            end: date.addingTimeInterval(Double(longest.upperBound) * Resolution.slot)
        )
    }

    /// Whether the person is awake at each slot across the next day.
    public static func awakeSlots(for person: Person, from date: Date) -> [Bool] {
        guard let timeZone = person.place.timeZone else {
            return Array(repeating: false, count: Resolution.slotCount)
        }
        return (0..<Resolution.slotCount).map { slot in
            let moment = date.addingTimeInterval(Double(slot) * Resolution.slot)
            return person.awakeHours.contains(localHour: LocalTime.hour(at: moment, in: timeZone))
        }
    }

    private static func longestRun(in slots: [Bool]) -> Range<Int>? {
        var best: Range<Int>?
        var runStart: Int?

        for index in slots.indices {
            if slots[index], runStart == nil {
                runStart = index
            }
            let runEnds = !slots[index] || index == slots.index(before: slots.endIndex)
            if runEnds, let start = runStart {
                let end = slots[index] ? index + 1 : index
                let run = start..<end
                if run.count > (best?.count ?? 0) { best = run }
                runStart = nil
            }
        }
        return best
    }
}

extension Overlap {
    /// How finely the next day is sampled when looking for shared waking hours.
    public enum Resolution {
        public static let slot: TimeInterval = 15 * 60
        /// 96 slots of 15 minutes covers exactly 24 hours.
        public static let slotCount = 96
        /// Shorter than half an hour is not worth suggesting as a time to call.
        public static let minimumSlots = 2
    }
}
