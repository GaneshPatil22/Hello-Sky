import Foundation

/// Steps a value from 0 to 1 over a duration, frame by frame.
///
/// Used where `withAnimation` cannot reach: a `Canvas` draws from whatever the
/// value is at that instant, so an animation SwiftUI applies to its own views
/// leaves the drawing to jump straight to the end while everything around it
/// slides. Stepping the value itself keeps the two in step.
@MainActor
enum Tween {
    /// Runs `step` with eased progress until it reaches 1.
    static func run(
        duration: TimeInterval,
        step: @escaping (Double) -> Void
    ) -> Task<Void, Never> {
        Task { @MainActor in
            let began = ContinuousClock.now
            while !Task.isCancelled {
                let progress = min(seconds(since: began) / duration, 1)
                step(eased(progress))
                if progress >= 1 { break }
                try? await Task.sleep(for: .milliseconds(Constants.stepMilliseconds))
            }
            if !Task.isCancelled { step(1) }
        }
    }

    /// Smoothstep: leaves and arrives gently.
    static func eased(_ t: Double) -> Double {
        let clamped = min(max(t, 0), 1)
        return clamped * clamped * (3 - 2 * clamped)
    }

    static func seconds(since instant: ContinuousClock.Instant) -> Double {
        let elapsed = (ContinuousClock.now - instant).components
        return Double(elapsed.seconds) + Double(elapsed.attoseconds) / Constants.attosecondsPerSecond
    }

    enum Constants {
        static let stepMilliseconds = 16
        static let attosecondsPerSecond: Double = 1e18
    }
}
