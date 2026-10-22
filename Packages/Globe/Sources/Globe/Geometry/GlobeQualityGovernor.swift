import Foundation

/// Watches frame times and lowers the tier when the globe cannot keep up.
///
/// Deliberately slow to react and slower to recover: a tier that flickers up
/// and down is more distracting than a tier that is simply one step low.
public struct GlobeQualityGovernor: Sendable {
    public private(set) var quality: GlobeQuality
    /// Set in testing to pin a tier and see how an older phone would look.
    public let isLocked: Bool

    private var slowFrames = 0
    private var fastFrames = 0

    public init(quality: GlobeQuality = .high, isLocked: Bool = false) {
        self.quality = quality
        self.isLocked = isLocked
    }

    /// Reports one frame's duration. Returns true if the tier changed.
    @discardableResult
    public mutating func record(frameDuration: TimeInterval) -> Bool {
        guard !isLocked else { return false }

        if frameDuration > Thresholds.slowFrame {
            slowFrames += 1
            fastFrames = 0
        } else if frameDuration < Thresholds.fastFrame {
            fastFrames += 1
            slowFrames = 0
        } else {
            return false
        }

        if slowFrames >= Thresholds.slowFramesBeforeDropping, let lower = quality.oneStepDown {
            quality = lower
            slowFrames = 0
            return true
        }
        if fastFrames >= Thresholds.fastFramesBeforeRaising, let higher = quality.oneStepUp {
            quality = higher
            fastFrames = 0
            return true
        }
        return false
    }
}

extension GlobeQualityGovernor {
    public enum Thresholds {
        /// Slower than this and a frame was late for 60Hz.
        public static let slowFrame: TimeInterval = 1.0 / 50
        /// Faster than this and there is room to spare.
        public static let fastFrame: TimeInterval = 1.0 / 90
        public static let slowFramesBeforeDropping = 30
        /// Four times as much evidence to go up as to come down.
        public static let fastFramesBeforeRaising = 120
    }
}

extension GlobeQuality {
    var oneStepDown: GlobeQuality? {
        switch self {
        case .high: .medium
        case .medium: .low
        case .low: nil
        }
    }

    var oneStepUp: GlobeQuality? {
        switch self {
        case .low: .medium
        case .medium: .high
        case .high: nil
        }
    }
}
