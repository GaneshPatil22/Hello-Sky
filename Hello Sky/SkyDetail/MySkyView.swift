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

    @State private var time = TimeTravel()

    var body: some View {
        if let you = store.people.first {
            SkyDetailView(person: you, weather: weather, time: time)
        } else {
            ContentUnavailableView(
                "No sky yet",
                systemImage: "sun.horizon",
                description: Text("Add yourself on the People tab to see your own sky.")
            )
        }
    }
}
