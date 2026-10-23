import Testing

@testable import SkyUI

@Suite("Sky colour")
struct SkyColorTests {
    @Test("Reads each byte of a hex value into the right channel")
    func decodesHex() {
        let color = SkyColor(hex: 0xFF8000)
        #expect(abs(color.red - 1.0) < 0.001)
        #expect(abs(color.green - 128.0 / 255.0) < 0.001)
        #expect(color.blue == 0)
    }

    @Test("Blending returns the endpoints at 0 and 1")
    func blendEndpoints() {
        let black = SkyColor(hex: 0x000000)
        let white = SkyColor(hex: 0xFFFFFF)
        #expect(black.blended(towards: white, amount: 0) == black)
        #expect(black.blended(towards: white, amount: 1) == white)
    }

    @Test("Blending clamps outside 0...1 rather than overshooting")
    func blendClamps() {
        let black = SkyColor(hex: 0x000000)
        let white = SkyColor(hex: 0xFFFFFF)
        #expect(black.blended(towards: white, amount: -1) == black)
        #expect(black.blended(towards: white, amount: 2) == white)
    }
}

@Suite("Colour components")
struct SkyColourComponentTests {
    @Test("Reads the hue of the primaries")
    func readsHue() {
        #expect(abs(SkyColor(hex: 0xFF0000).components.hue - 0) < 0.01)
        #expect(abs(SkyColor(hex: 0x00FF00).components.hue - 1.0 / 3) < 0.01)
        #expect(abs(SkyColor(hex: 0x0000FF).components.hue - 2.0 / 3) < 0.01)
    }

    @Test("Grey has no hue to speak of")
    func greyIsUnsaturated() {
        #expect(SkyColor(hex: 0x808080).components.saturation < 0.01)
        #expect(SkyColor(hex: 0xFFFFFF).components.saturation < 0.01)
    }

    @Test("Survives a round trip through hue, saturation and brightness")
    func roundTrip() {
        for hex: UInt32 in [0xFF8000, 0x3366CC, 0x12E6A0, 0x884422, 0xFFFFFF, 0x101010] {
            let original = SkyColor(hex: hex)
            let parts = original.components
            let rebuilt = SkyColor(hue: parts.hue, saturation: parts.saturation, brightness: parts.brightness)
            #expect(abs(rebuilt.red - original.red) < 0.01, "\(String(hex, radix: 16))")
            #expect(abs(rebuilt.green - original.green) < 0.01, "\(String(hex, radix: 16))")
            #expect(abs(rebuilt.blue - original.blue) < 0.01, "\(String(hex, radix: 16))")
        }
    }

    @Test("An accent keeps the hue and takes a usable brightness")
    func accentKeepsHue() {
        // The bug this guards: an accent that only ever got lighter or darker,
        // so dawn and midday looked the same.
        let dawn = SkyColor(hex: 0x6B3A12).asAccent()
        let noon = SkyColor(hex: 0x1B4A8A).asAccent()

        #expect(abs(dawn.components.brightness - SkyColor.Accent.brightness) < 0.01)
        #expect(abs(noon.components.brightness - SkyColor.Accent.brightness) < 0.01)
        #expect(abs(dawn.components.hue - noon.components.hue) > 0.1, "dawn and noon should differ in hue")
        #expect(dawn.red > dawn.blue, "dawn should be warm")
        #expect(noon.blue > noon.red, "noon should be cool")
    }

    @Test("Saturation is capped so the accent stays a tint")
    func accentIsNotGaudy() {
        #expect(SkyColor(hex: 0xFF0000).asAccent().components.saturation <= SkyColor.Accent.saturation + 0.01)
    }
}
