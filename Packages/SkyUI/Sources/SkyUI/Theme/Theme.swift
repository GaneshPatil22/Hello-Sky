import Foundation

/// A look: everything that changes when the user picks a different style.
///
/// A theme is data. Adding a look means adding one file that builds a `Theme`
/// and registering it; no screen contains look-specific code.
public struct Theme: Sendable, Identifiable {
    /// Stable across releases — it is what gets persisted in settings.
    public let id: String
    /// Shown in the look picker.
    ///
    /// Phase 8 adds the String Catalog these resolve against; until then they
    /// fall back to the literal.
    public let name: LocalizedStringResource
    public let sky: SkyPalette
    public let globe: GlobeStyle
    public let accent: SkyColor
    public let starTint: SkyColor
    /// The alternate app icon this look switches to, or `nil` for the default icon.
    public let alternateIconName: String?

    public init(
        id: String,
        name: LocalizedStringResource,
        sky: SkyPalette,
        globe: GlobeStyle,
        accent: SkyColor,
        starTint: SkyColor,
        alternateIconName: String?
    ) {
        self.id = id
        self.name = name
        self.sky = sky
        self.globe = globe
        self.accent = accent
        self.starTint = starTint
        self.alternateIconName = alternateIconName
    }
}

extension Theme: Hashable {
    /// Identity is the id alone: two values with the same id are the same look,
    /// whatever has been tuned inside it.
    public static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
