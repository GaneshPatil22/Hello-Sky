import Foundation

/// A random number generator that always produces the same sequence from the
/// same seed.
///
/// The sky's stars, clouds, and hills are placed randomly but must not move
/// between launches: a place should look like itself, and snapshot tests
/// compare rendered images.
public struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        // Zero is a fixed point of the mixer, so nudge it off.
        state = seed == 0 ? Constants.fallbackSeed : seed
    }

    public mutating func next() -> UInt64 {
        // SplitMix64: small, fast, and good enough for scattering stars.
        state &+= Constants.gamma
        var z = state
        z = (z ^ (z >> 30)) &* Constants.mix1
        z = (z ^ (z >> 27)) &* Constants.mix2
        return z ^ (z >> 31)
    }

    /// The next value in `0..<1`.
    public mutating func nextFraction() -> Double {
        Double(next() >> 11) * Constants.fractionScale
    }

    /// The next value inside `range`.
    public mutating func next(in range: ClosedRange<Double>) -> Double {
        range.lowerBound + nextFraction() * (range.upperBound - range.lowerBound)
    }
}

extension SeededGenerator {
    private enum Constants {
        static let fallbackSeed: UInt64 = 0x9E37_79B9_7F4A_7C15
        static let gamma: UInt64 = 0x9E37_79B9_7F4A_7C15
        static let mix1: UInt64 = 0xBF58_476D_1CE4_E5B9
        static let mix2: UInt64 = 0x94D0_49BB_1331_11EB
        static let fractionScale = 1.0 / 9_007_199_254_740_992.0 // 2^53
    }
}
