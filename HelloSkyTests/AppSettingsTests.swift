import Foundation
import Testing

@testable import Hello_Sky

@MainActor
@Suite("App settings")
struct AppSettingsTests {
    /// A throwaway store, so tests never touch the real one.
    private func store() -> UserDefaults {
        let suite = UserDefaults(suiteName: "settings-\(UUID().uuidString)")!
        return suite
    }

    @Test("Starts on sensible defaults")
    func defaults() {
        let settings = AppSettings(store: store())
        #expect(settings.homePersonID == nil)
        #expect(!settings.usesTwentyFourHourTime)
        #expect(!settings.usesFahrenheit)
        #expect(!settings.prefersReducedMotion)
        #expect(settings.themeID == AppSettings.Defaults.theme)
    }

    @Test("Choices survive relaunching")
    func persists() {
        let shared = store()
        let first = AppSettings(store: shared)
        first.homePersonID = "kenji"
        first.usesTwentyFourHourTime = true
        first.usesFahrenheit = true
        first.prefersReducedMotion = true
        first.themeID = "ink"

        let reopened = AppSettings(store: shared)
        #expect(reopened.homePersonID == "kenji")
        #expect(reopened.usesTwentyFourHourTime)
        #expect(reopened.usesFahrenheit)
        #expect(reopened.prefersReducedMotion)
        #expect(reopened.themeID == "ink")
    }

    @Test("Clearing the home person is remembered too")
    func clearingHomePersists() {
        let shared = store()
        let first = AppSettings(store: shared)
        first.homePersonID = "kenji"
        first.homePersonID = nil

        #expect(AppSettings(store: shared).homePersonID == nil)
    }
}
