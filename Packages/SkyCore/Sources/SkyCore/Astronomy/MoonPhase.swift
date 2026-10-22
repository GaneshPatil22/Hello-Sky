import Foundation

/// Where the moon is in its cycle.
public struct MoonPhase: Hashable, Sendable {
    /// Position through the synodic month, from 0 at new moon to 1 at the next new moon.
    public let fraction: Double
    /// How much of the disc is lit, from 0 at new to 1 at full.
    public let illumination: Double

    /// The named phase, for labels and for picking the shape to draw.
    public var name: Name {
        Name(fraction: fraction)
    }

    /// Whether the moon is heading towards full.
    public var isWaxing: Bool {
        fraction < Name.Boundaries.full
    }
}

extension MoonPhase {
    public enum Name: String, Hashable, Sendable, CaseIterable {
        case new
        case waxingCrescent
        case firstQuarter
        case waxingGibbous
        case full
        case waningGibbous
        case lastQuarter
        case waningCrescent

        init(fraction: Double) {
            // Each named phase is centred on its fraction and half a slice wide,
            // so "full" covers a few days either side of exactly full.
            let slice = 1.0 / Double(Self.allCases.count)
            let index = Int((fraction + slice / 2).truncatingRemainder(dividingBy: 1) / slice)
            self = Self.allCases[min(index, Self.allCases.count - 1)]
        }
    }
}

extension MoonPhase.Name {
    enum Boundaries {
        static let full = 0.5
    }
}
