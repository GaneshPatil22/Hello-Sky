import Foundation
import Observation
import SkyData

/// Opens the people store once, at launch.
///
/// Opening can fail — a store written by a newer version, or a disk with no
/// room. The failure is kept rather than swallowed, so the app can say so
/// instead of starting up pretending to have no people.
@MainActor
@Observable
final class AppStartup {
    enum State {
        case ready(PeopleStore)
        case failed(String)
    }

    let state: State
    /// Built whatever happens to the store: weather never fails, so there is
    /// nothing to recover from here.
    let weather = WeatherSource.makeRepository()
    let settings = AppSettings()

    init() {
        do {
            let store = try PeopleStore()
            #if DEBUG
            // An empty globe tells you nothing about whether the globe works.
            try? store.seedWithFixtures()
            #endif
            state = .ready(store)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
