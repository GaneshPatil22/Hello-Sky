import Foundation
import Observation

/// The handful of choices the app remembers.
///
/// Backed by `UserDefaults` directly rather than `@AppStorage`, which does not
/// drive updates from inside an `@Observable` type.
@MainActor
@Observable
final class AppSettings {
    /// Whose globe this is. Every arc starts here.
    var homePersonID: String? {
        didSet { store.set(homePersonID, forKey: Key.homePerson) }
    }

    var usesTwentyFourHourTime: Bool {
        didSet { store.set(usesTwentyFourHourTime, forKey: Key.twentyFourHour) }
    }

    var usesFahrenheit: Bool {
        didSet { store.set(usesFahrenheit, forKey: Key.fahrenheit) }
    }

    /// A manual override on top of the system's Reduce Motion setting.
    var prefersReducedMotion: Bool {
        didSet { store.set(prefersReducedMotion, forKey: Key.reduceMotion) }
    }

    var themeID: String {
        didSet { store.set(themeID, forKey: Key.theme) }
    }

    private let store: UserDefaults

    init(store: UserDefaults = .standard) {
        self.store = store
        homePersonID = store.string(forKey: Key.homePerson)
        usesTwentyFourHourTime = store.bool(forKey: Key.twentyFourHour)
        usesFahrenheit = store.bool(forKey: Key.fahrenheit)
        prefersReducedMotion = store.bool(forKey: Key.reduceMotion)
        themeID = store.string(forKey: Key.theme) ?? Defaults.theme
    }

    private enum Key {
        static let homePerson = "homePersonID"
        static let twentyFourHour = "usesTwentyFourHourTime"
        static let fahrenheit = "usesFahrenheit"
        static let reduceMotion = "prefersReducedMotion"
        static let theme = "themeID"
    }

    enum Defaults {
        static let theme = "realistic"
    }
}
