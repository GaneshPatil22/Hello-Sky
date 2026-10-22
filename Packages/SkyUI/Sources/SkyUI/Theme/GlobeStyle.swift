import Foundation

/// How a look draws the Earth.
///
/// Phase 5 reads these as shader settings; nothing here is a view.
public struct GlobeStyle: Hashable, Sendable {
    /// Blends the three land colours into the shade for one light level.
    ///
    /// `light` runs 0 for the far side of night to 1 for full daylight.
    public func landShade(light: Double) -> SkyColor {
        let amount = min(max(light, 0), 1)
        return amount < 0.5
            ? landNight.blended(towards: landTerminator, amount: amount * 2)
            : landTerminator.blended(towards: landDay, amount: (amount - 0.5) * 2)
    }

    /// Whether the Earth is drawn from photographic textures or as the stylised dot grid.
    public enum Surface: String, Hashable, Sendable, CaseIterable {
        case textured
        case dotted
    }

    public let surface: Surface
    /// Asset names, or `nil` to use the shared defaults.
    public let dayTextureName: String?
    public let nightTextureName: String?
    /// Multiplied over the textures, which is how Dusk warms the same imagery.
    public let tint: SkyColor?
    public let atmosphere: SkyColor
    public let cityLights: SkyColor
    /// How wide the day/night line is, in degrees of arc.
    public let terminatorSoftness: Double
    /// The ocean, from the sunlit centre out to the limb.
    public let oceanLit: SkyColor
    public let oceanDeep: SkyColor
    /// Land through the day, from the far side of night to full daylight.
    /// The middle colour is the warm band along the day/night line.
    public let landNight: SkyColor
    public let landTerminator: SkyColor
    public let landDay: SkyColor
    /// The wash laid over the night half.
    public let nightShade: SkyColor
    public let graticule: SkyColor

    public init(
        surface: Surface,
        dayTextureName: String? = nil,
        nightTextureName: String? = nil,
        tint: SkyColor? = nil,
        atmosphere: SkyColor,
        cityLights: SkyColor,
        terminatorSoftness: Double,
        oceanLit: SkyColor,
        oceanDeep: SkyColor,
        landNight: SkyColor,
        landTerminator: SkyColor,
        landDay: SkyColor,
        nightShade: SkyColor,
        graticule: SkyColor
    ) {
        self.surface = surface
        self.dayTextureName = dayTextureName
        self.nightTextureName = nightTextureName
        self.tint = tint
        self.atmosphere = atmosphere
        self.cityLights = cityLights
        self.terminatorSoftness = terminatorSoftness
        self.oceanLit = oceanLit
        self.oceanDeep = oceanDeep
        self.landNight = landNight
        self.landTerminator = landTerminator
        self.landDay = landDay
        self.nightShade = nightShade
        self.graticule = graticule
    }
}
