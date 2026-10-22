import Foundation

/// How a look draws the Earth.
///
/// Phase 5 reads these as shader settings; nothing here is a view.
public struct GlobeStyle: Hashable, Sendable {
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

    public init(
        surface: Surface,
        dayTextureName: String? = nil,
        nightTextureName: String? = nil,
        tint: SkyColor? = nil,
        atmosphere: SkyColor,
        cityLights: SkyColor,
        terminatorSoftness: Double
    ) {
        self.surface = surface
        self.dayTextureName = dayTextureName
        self.nightTextureName = nightTextureName
        self.tint = tint
        self.atmosphere = atmosphere
        self.cityLights = cityLights
        self.terminatorSoftness = terminatorSoftness
    }
}
