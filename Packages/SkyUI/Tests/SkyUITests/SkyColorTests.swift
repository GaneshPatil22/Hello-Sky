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
