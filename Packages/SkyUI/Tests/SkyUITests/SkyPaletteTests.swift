import Testing

@testable import SkyUI

@Suite("Sky palette")
struct SkyPaletteTests {
    private let black = SkyColor(hex: 0x000000)
    private let white = SkyColor(hex: 0xFFFFFF)

    private var twoStop: SkyPalette {
        SkyPalette(keyframes: [
            SkyKeyframe(elevation: 0, gradient: SkyGradient(top: black, horizon: black)),
            SkyKeyframe(elevation: 10, gradient: SkyGradient(top: white, horizon: white)),
        ])
    }

    @Test("Returns the exact gradient at a keyframe")
    func exactAtKeyframe() {
        #expect(twoStop.gradient(forSunElevation: 0).top == black)
        #expect(twoStop.gradient(forSunElevation: 10).top == white)
    }

    @Test("Blends halfway between two keyframes")
    func blendsBetweenKeyframes() {
        let middle = twoStop.gradient(forSunElevation: 5).top
        #expect(abs(middle.red - 0.5) < 0.001)
        #expect(abs(middle.green - 0.5) < 0.001)
        #expect(abs(middle.blue - 0.5) < 0.001)
    }

    @Test("Clamps outside the table instead of extrapolating")
    func clampsAtTheEnds() {
        #expect(twoStop.gradient(forSunElevation: -90).top == black)
        #expect(twoStop.gradient(forSunElevation: 90).top == white)
    }

    @Test("Sorts keyframes given out of order")
    func sortsKeyframes() {
        let palette = SkyPalette(keyframes: [
            SkyKeyframe(elevation: 10, gradient: SkyGradient(top: white, horizon: white)),
            SkyKeyframe(elevation: 0, gradient: SkyGradient(top: black, horizon: black)),
        ])
        #expect(palette.keyframes.map(\.elevation) == [0, 10])
        #expect(palette.gradient(forSunElevation: 0).top == black)
    }

    @Test("Every shipped look covers the full elevation range without a jump")
    func shippedLooksAreContinuous() {
        for theme in ThemeRegistry.standard.themes {
            var previous = theme.sky.gradient(forSunElevation: -90).top
            for degrees in stride(from: -90.0, through: 90.0, by: 1.0) {
                let current = theme.sky.gradient(forSunElevation: degrees).top
                let jump = max(abs(current.red - previous.red),
                               abs(current.green - previous.green),
                               abs(current.blue - previous.blue))
                #expect(jump < 0.25, "\(theme.name) jumps at \(degrees)°")
                previous = current
            }
        }
    }
}
