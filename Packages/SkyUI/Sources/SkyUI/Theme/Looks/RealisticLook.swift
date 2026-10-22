import Foundation

extension Theme {
    /// Calm and true to life: photographic Earth, physically inspired sky.
    ///
    /// Colour values are a starting point, tuned on device rather than derived.
    public static let realistic = Theme(
        id: "realistic",
        name: "Realistic",
        sky: SkyPalette(keyframes: [
            SkyKeyframe(elevation: SkyPalette.Elevation.deepNight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x01030C), horizon: SkyColor(hex: 0x040A1C))),
            SkyKeyframe(elevation: SkyPalette.Elevation.astronomicalTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x030619), horizon: SkyColor(hex: 0x0B1338))),
            SkyKeyframe(elevation: SkyPalette.Elevation.nauticalTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x0A1139), horizon: SkyColor(hex: 0x1C2C66))),
            SkyKeyframe(elevation: SkyPalette.Elevation.civilTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x1B2C70), horizon: SkyColor(hex: 0x614D91))),
            SkyKeyframe(elevation: SkyPalette.Elevation.blueHour,
                        gradient: SkyGradient(top: SkyColor(hex: 0x2D4C9E), horizon: SkyColor(hex: 0xF28C5F))),
            SkyKeyframe(elevation: SkyPalette.Elevation.sunrise,
                        gradient: SkyGradient(top: SkyColor(hex: 0x3F6ABC), horizon: SkyColor(hex: 0xFFB66D))),
            SkyKeyframe(elevation: SkyPalette.Elevation.goldenHour,
                        gradient: SkyGradient(top: SkyColor(hex: 0x5088DA), horizon: SkyColor(hex: 0xFFDCA3))),
            SkyKeyframe(elevation: SkyPalette.Elevation.morning,
                        gradient: SkyGradient(top: SkyColor(hex: 0x5B9DEA), horizon: SkyColor(hex: 0xD2E8FC))),
            SkyKeyframe(elevation: SkyPalette.Elevation.midMorning,
                        gradient: SkyGradient(top: SkyColor(hex: 0x3E88E4), horizon: SkyColor(hex: 0xAAD6F8))),
            SkyKeyframe(elevation: SkyPalette.Elevation.zenith,
                        gradient: SkyGradient(top: SkyColor(hex: 0x307ADA), horizon: SkyColor(hex: 0x91CAF6))),
        ]),
        globe: GlobeStyle(
            surface: .textured,
            atmosphere: SkyColor(hex: 0x6EAAFF),
            cityLights: SkyColor(hex: 0xFFCE80),
            terminatorSoftness: 3.0,
            oceanLit: SkyColor(hex: 0x2B66A8),
            oceanDeep: SkyColor(hex: 0x081E4C),
            landNight: SkyColor(hex: 0x1E2C4C),
            landTerminator: SkyColor(hex: 0xFF9E60),
            landDay: SkyColor(hex: 0xBAE6C4),
            nightShade: SkyColor(hex: 0x02060F),
            graticule: SkyColor(hex: 0xFFFFFF)
        ),
        accent: SkyColor(hex: 0x4F93F5),
        starTint: SkyColor(hex: 0xFFFFFF),
        alternateIconName: nil
    )
}
