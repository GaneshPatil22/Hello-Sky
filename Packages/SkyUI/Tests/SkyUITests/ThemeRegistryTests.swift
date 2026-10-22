import Foundation
import Testing

@testable import SkyUI

@Suite("Theme registry")
struct ThemeRegistryTests {
    @Test("Ships the three v1 looks")
    func shipsThreeLooks() {
        #expect(ThemeRegistry.standard.themes.map(\.id) == ["realistic", "dusk", "ink"])
    }

    @Test("A look added only through the registry is offered to the picker")
    func addingALookNeedsNoScreenChanges() {
        let extra = Theme(
            id: "test-look",
            name: "Test Look",
            sky: Theme.ink.sky,
            globe: Theme.ink.globe,
            accent: SkyColor(hex: 0x00FF00),
            starTint: SkyColor(hex: 0xFFFFFF),
            alternateIconName: nil
        )
        let registry = ThemeRegistry(themes: ThemeRegistry.standard.themes + [extra])

        #expect(registry.themes.count == ThemeRegistry.standard.themes.count + 1)
        #expect(registry.theme(id: "test-look") == extra)
    }

    @Test("Falls back to the default when a stored look no longer exists")
    func unknownStoredIDFallsBack() {
        let registry = ThemeRegistry.standard
        #expect(registry.theme(storedID: "removed-look") == registry.defaultTheme)
        #expect(registry.theme(storedID: nil) == registry.defaultTheme)
        #expect(registry.theme(storedID: "ink") == .ink)
    }

    @Test("Every look carries a full sky table and a unique id")
    func looksAreWellFormed() {
        for theme in ThemeRegistry.standard.themes {
            #expect(!theme.sky.keyframes.isEmpty, "\(theme.name) has an empty sky table")
            #expect(!String(localized: theme.name).isEmpty)
        }
    }
}
