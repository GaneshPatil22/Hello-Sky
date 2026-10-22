import Foundation

/// The looks the app offers.
///
/// Screens, settings, and the look picker all read from a registry rather than
/// from a hard-coded list, so a new look reaches the whole app by being added here.
public struct ThemeRegistry: Hashable, Sendable {
    public let themes: [Theme]

    /// The first theme, used when nothing is stored or a stored id no longer exists.
    public var defaultTheme: Theme { themes[0] }

    /// - Precondition: `themes` is not empty and its ids are unique.
    public init(themes: [Theme]) {
        precondition(!themes.isEmpty, "A registry needs at least one theme")
        precondition(Set(themes.map(\.id)).count == themes.count, "Theme ids must be unique")
        self.themes = themes
    }

    public func theme(id: String) -> Theme? {
        themes.first { $0.id == id }
    }

    /// The stored look, falling back to the default when the id is unknown.
    public func theme(storedID: String?) -> Theme {
        storedID.flatMap(theme(id:)) ?? defaultTheme
    }
}

extension ThemeRegistry {
    /// The looks that ship in v1.
    public static let standard = ThemeRegistry(themes: [.realistic, .dusk, .ink])
}
