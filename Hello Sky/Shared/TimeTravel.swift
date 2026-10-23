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
    private(set) var offsetHours: Double = 0

    /// What the slider binds to.
    ///
    /// Writing through here stops a return that is under way, so dragging
    /// always wins over an animation still finishing.
    var scrubbedOffset: Double {
        get { offsetHours }
        set {
            cancelReturn()
            offsetHours = newValue
        }
    }

    @ObservationIgnored private var returnTask: Task<Void, Never>?

    /// The moment every screen should draw.
    func date(from now: Date = .now) -> Date {
        now.addingTimeInterval(offsetHours * Constants.secondsPerHour)
    }

    var isNow: Bool { offsetHours == 0 }

    /// Winds the clock back to now over a moment, so the day/night line travels
    /// there rather than jumping.
    ///
    /// Stepped by hand because the globe is drawn in a `Canvas`: SwiftUI cannot
    /// interpolate a value it only sees inside a drawing closure, so an
    /// animation around the assignment would still arrive in one jump.
    func returnToNow() {
        cancelReturn()
        let start = offsetHours
        guard start != 0 else { return }

        returnTask = Task { @MainActor [weak self] in
            // A monotonic clock, so the wind-back is unaffected if the wall
            // clock shifts under it.
            let began = ContinuousClock.now
            while !Task.isCancelled {
                let progress = min(Self.seconds(since: began) / Constants.returnDuration, 1)
                self?.offsetHours = start * (1 - Self.eased(progress))

                if progress >= 1 { break }
                try? await Task.sleep(for: .milliseconds(Constants.stepMilliseconds))
            }
            guard !Task.isCancelled else { return }
            self?.offsetHours = 0
        }
    }

    /// Goes straight there, for Reduce Motion.
    func jumpToNow() {
        cancelReturn()
        offsetHours = 0
    }

    func cancelReturn() {
        returnTask?.cancel()
        returnTask = nil
    }

    static func seconds(since instant: ContinuousClock.Instant) -> Double {
        let elapsed = (ContinuousClock.now - instant).components
        return Double(elapsed.seconds) + Double(elapsed.attoseconds) / Constants.attosecondsPerSecond
    }

    /// Smoothstep: leaves and arrives gently, which is what stops the
    /// terminator setting off with a lurch.
    static func eased(_ t: Double) -> Double {
        let clamped = min(max(t, 0), 1)
        return clamped * clamped * (3 - 2 * clamped)
    }

    enum Constants {
        static let secondsPerHour: Double = 3_600
        /// Half a day back, a full day forward: the window the slider covers.
        static let range: ClosedRange<Double> = -12...24
        static let step: Double = 0.25
        /// Long enough to read as travel, short enough not to be in the way.
        static let returnDuration: Double = 0.85
        static let stepMilliseconds = 16
        static let attosecondsPerSecond: Double = 1e18
    }
}
