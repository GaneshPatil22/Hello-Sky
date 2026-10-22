import SwiftUI

/// A colour stored as plain numbers so it can be blended and compared in tests.
///
/// SwiftUI's `Color` cannot be interpolated or inspected, so look data keeps its
/// own representation and converts at the edge, where it meets a view.
public struct SkyColor: Hashable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Builds a colour from a 24-bit hex value, written as `0x1B2A63`.
    public init(hex: UInt32) {
        self.init(
            red: Double((hex >> Shift.red) & Mask.byte) / Scale.byteMaximum,
            green: Double((hex >> Shift.green) & Mask.byte) / Scale.byteMaximum,
            blue: Double(hex & Mask.byte) / Scale.byteMaximum
        )
    }

    public var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: Scale.fullOpacity)
    }

    /// Blends towards `other`, where `amount` of 0 returns this colour and 1 returns `other`.
    public func blended(towards other: SkyColor, amount: Double) -> SkyColor {
        let t = min(max(amount, Scale.blendRange.lowerBound), Scale.blendRange.upperBound)
        return SkyColor(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t
        )
    }
}

extension SkyColor {
    private enum Shift {
        static let red: UInt32 = 16
        static let green: UInt32 = 8
    }

    private enum Mask {
        static let byte: UInt32 = 0xFF
    }

    private enum Scale {
        static let byteMaximum = 255.0
        static let fullOpacity = 1.0
        static let blendRange: ClosedRange<Double> = 0...1
    }
}
