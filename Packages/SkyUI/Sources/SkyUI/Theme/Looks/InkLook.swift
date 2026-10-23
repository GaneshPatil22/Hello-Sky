import Foundation

extension Theme {
    /// Minimal and graphic: greyscale sky, dotted globe, one accent colour.
    public static let ink = Theme(
        id: "ink",
        name: "Ink",
        sky: SkyPalette(keyframes: [
            SkyKeyframe(elevation: SkyPalette.Elevation.deepNight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x030303), horizon: SkyColor(hex: 0x090909))),
            SkyKeyframe(elevation: SkyPalette.Elevation.astronomicalTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x070707), horizon: SkyColor(hex: 0x141416))),
            SkyKeyframe(elevation: SkyPalette.Elevation.nauticalTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x0B0B0C), horizon: SkyColor(hex: 0x1D1D1F))),
            SkyKeyframe(elevation: SkyPalette.Elevation.civilTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x252527), horizon: SkyColor(hex: 0x7B7B7F))),
            SkyKeyframe(elevation: SkyPalette.Elevation.blueHour,
                        gradient: SkyGradient(top: SkyColor(hex: 0x303033), horizon: SkyColor(hex: 0xA8A8AC))),
            SkyKeyframe(elevation: SkyPalette.Elevation.sunrise,
                        gradient: SkyGradient(top: SkyColor(hex: 0x3B3B3E), horizon: SkyColor(hex: 0xD1D1D3))),
            SkyKeyframe(elevation: SkyPalette.Elevation.goldenHour,
                        gradient: SkyGradient(top: SkyColor(hex: 0x56565A), horizon: SkyColor(hex: 0xE2E2E4))),
            SkyKeyframe(elevation: SkyPalette.Elevation.morning,
                        gradient: SkyGradient(top: SkyColor(hex: 0x67676B), horizon: SkyColor(hex: 0xE9E9EB))),
            SkyKeyframe(elevation: SkyPalette.Elevation.midMorning,
                        gradient: SkyGradient(top: SkyColor(hex: 0x8B8B8F), horizon: SkyColor(hex: 0xF3F3F5))),
            SkyKeyframe(elevation: SkyPalette.Elevation.zenith,
                        gradient: SkyGradient(top: SkyColor(hex: 0x9B9B9F), horizon: SkyColor(hex: 0xFAFAFA))),
        ]),
        globe: GlobeStyle(
            surface: .dotted,
            atmosphere: SkyColor(hex: 0xDCDCE1),
            cityLights: SkyColor(hex: 0xFFFFFF),
            terminatorSoftness: 1.0,
            oceanLit: SkyColor(hex: 0x2A2A2D),
            oceanDeep: SkyColor(hex: 0x101012),
            landNight: SkyColor(hex: 0x343438),
            landTerminator: SkyColor(hex: 0xAAAAAC),
            landDay: SkyColor(hex: 0xF0F0F0),
            nightShade: SkyColor(hex: 0x040405),
            graticule: SkyColor(hex: 0xFFFFFF),
            arcTint: SkyColor(hex: 0xFFD60A)
        ),
        accent: SkyColor(hex: 0xFFD60A),
        starTint: SkyColor(hex: 0xFFFFFF),
        alternateIconName: "AppIcon-Ink"
    )
}
