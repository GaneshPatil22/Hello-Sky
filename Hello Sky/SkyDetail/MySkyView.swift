import SkyCore
import SkyData
import SkyUI
import SwiftUI

/// Your own sky, which is the same screen as anyone else's.
///
/// "You" is the first person on the list, matching the prototype, until
/// settings let a home city be chosen outright.
struct MySkyView: View {
    let store: PeopleStore
    let weather: WeatherRepository
    @Bindable var settings: AppSettings
    /// Where the back button goes. A sky shown as a tab has nothing to dismiss,
    /// so without this the button did nothing at all.
    let onBack: () -> Void

    @State private var time = TimeTravel()

    /// Your own sky is the home person's, which settings can change.
    private var home: Person? {
        if let id = settings.homePersonID, let match = store.people.first(where: { $0.id == id }) {
            return match
        }
        return store.people.first
    }

    var body: some View {
        if let you = home {
            SkyDetailView(person: you, home: you, weather: weather, time: time,
                          settings: settings, onClose: onBack)
        } else {
            ContentUnavailableView(
                "No sky yet",
                systemImage: "sun.horizon",
                description: Text("Add yourself on the People tab to see your own sky.")
            )
        }
    }
}
