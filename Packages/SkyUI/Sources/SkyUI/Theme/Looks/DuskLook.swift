import Foundation

extension Theme {
    /// Warm and illustrated: the same Earth, tinted towards evening.
    public static let dusk = Theme(
        id: "dusk",
        name: "Dusk",
        sky: SkyPalette(keyframes: [
            SkyKeyframe(elevation: SkyPalette.Elevation.deepNight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x09051A), horizon: SkyColor(hex: 0x180C30))),
            SkyKeyframe(elevation: SkyPalette.Elevation.astronomicalTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x0C0726), horizon: SkyColor(hex: 0x251141))),
            SkyKeyframe(elevation: SkyPalette.Elevation.nauticalTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x1A0C38), horizon: SkyColor(hex: 0x431858))),
            SkyKeyframe(elevation: SkyPalette.Elevation.civilTwilight,
                        gradient: SkyGradient(top: SkyColor(hex: 0x241048), horizon: SkyColor(hex: 0x5C2068))),
            SkyKeyframe(elevation: SkyPalette.Elevation.blueHour,
                        gradient: SkyGradient(top: SkyColor(hex: 0x4B1E70), horizon: SkyColor(hex: 0xE2527C))),
            SkyKeyframe(elevation: SkyPalette.Elevation.sunrise,
                        gradient: SkyGradient(top: SkyColor(hex: 0x6E2F84), horizon: SkyColor(hex: 0xFF8C6D))),
            SkyKeyframe(elevation: SkyPalette.Elevation.goldenHour,
                        gradient: SkyGradient(top: SkyColor(hex: 0x8C4C9C), horizon: SkyColor(hex: 0xFFC28C))),
            SkyKeyframe(elevation: SkyPalette.Elevation.morning,
                        gradient: SkyGradient(top: SkyColor(hex: 0x7F6DB7), horizon: SkyColor(hex: 0xFFD9B2))),
            SkyKeyframe(elevation: SkyPalette.Elevation.midMorning,
                        gradient: SkyGradient(top: SkyColor(hex: 0x6181D2), horizon: SkyColor(hex: 0xFFE5CA))),
            SkyKeyframe(elevation: SkyPalette.Elevation.zenith,
                        gradient: SkyGradient(top: SkyColor(hex: 0x4C71D2), horizon: SkyColor(hex: 0xF6E3D2))),
        ]),
        globe: GlobeStyle(
            surface: .textured,
            tint: SkyColor(hex: 0xFFB38A),
            atmosphere: SkyColor(hex: 0xFF8CAA),
            cityLights: SkyColor(hex: 0xFFA8C6),
            terminatorSoftness: 5.0,
            oceanLit: SkyColor(hex: 0x8A5BA0),
            oceanDeep: SkyColor(hex: 0x1E1040),
            landNight: SkyColor(hex: 0x42285A),
            landTerminator: SkyColor(hex: 0xFF707A),
            landDay: SkyColor(hex: 0xFFCEA0),
            nightShade: SkyColor(hex: 0x0A0418),
            graticule: SkyColor(hex: 0xFFD9E6),
            arcTint: SkyColor(hex: 0xFFCB7A)
        ),
        accent: SkyColor(hex: 0xFFB38A),
        starTint: SkyColor(hex: 0xFFE2EC),
        alternateIconName: "AppIcon-Dusk"
    )
}
