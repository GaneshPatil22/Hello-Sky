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

extension SkyColor {
    /// Hue, saturation and brightness, as fractions from 0 to 1.
    ///
    /// Needed because the interesting changes in a sky are changes of hue —
    /// orange at dawn, blue at noon, indigo at night — and those are invisible
    /// if a colour is only ever made lighter or darker.
    public var components: (hue: Double, saturation: Double, brightness: Double) {
        let highest = max(red, green, blue)
        let lowest = min(red, green, blue)
        let range = highest - lowest

        guard range > Accent.flat else { return (0, 0, highest) }

        let hue: Double = switch highest {
        case red: ((green - blue) / range).truncatingRemainder(dividingBy: 6)
        case green: (blue - red) / range + 2
        default: (red - green) / range + 4
        }
        let wrapped = hue < 0 ? hue + 6 : hue
        return (wrapped / 6, range / highest, highest)
    }

    public init(hue: Double, saturation: Double, brightness: Double) {
        let sector = (hue - hue.rounded(.down)) * 6
        let offset = sector - sector.rounded(.down)
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - saturation * offset)
        let t = brightness * (1 - saturation * (1 - offset))

        switch Int(sector) {
        case 0: self.init(red: brightness, green: t, blue: p)
        case 1: self.init(red: q, green: brightness, blue: p)
        case 2: self.init(red: p, green: brightness, blue: t)
        case 3: self.init(red: p, green: q, blue: brightness)
        case 4: self.init(red: t, green: p, blue: brightness)
        default: self.init(red: brightness, green: p, blue: q)
        }
    }

    /// The same colour brought to a usable brightness, with its hue kept and
    /// its saturation eased so it reads as a tint rather than a paint.
    public func asAccent(
        brightness target: Double = Accent.brightness,
        saturation cap: Double = Accent.saturation
    ) -> SkyColor {
        let parts = components
        return SkyColor(
            hue: parts.hue,
            saturation: min(parts.saturation, cap),
            brightness: target
        )
    }

    public enum Accent {
        public static let brightness = 0.86
        /// Held well below full, or the accent competes with the sky.
        public static let saturation = 0.30
        /// Below this the three channels are equal and there is no hue to find.
        static let flat = 0.0001
    }
}
