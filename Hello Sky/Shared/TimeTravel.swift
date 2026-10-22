import Foundation
import Observation

/// The one clock every screen reads.
///
/// The time slider moves this, and the globe, the chips and the sky all follow,
/// so nothing can disagree about what moment is being shown.
@MainActor
@Observable
final class TimeTravel {
    /// Hours away from now, which the slider writes.
    var offsetHours: Double = 0

    /// The moment every screen should draw.
    func date(from now: Date = .now) -> Date {
        now.addingTimeInterval(offsetHours * Constants.secondsPerHour)
    }

    var isNow: Bool { offsetHours == 0 }

    func reset() { offsetHours = 0 }

    enum Constants {
        static let secondsPerHour: Double = 3_600
        /// Half a day back, a full day forward: the window the slider covers.
        static let range: ClosedRange<Double> = -12...24
        static let step: Double = 0.25
    }
}
