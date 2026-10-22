import SkyData
import SwiftUI

/// The app's three places: the globe, your own sky, and the people list.
struct HomeView: View {
    let store: PeopleStore
    let weather: WeatherRepository

    @State private var tab: Section = .globe

    var body: some View {
        TabView(selection: $tab) {
            Tab("Globe", systemImage: "globe", value: Section.globe) {
                GlobeHomeView(store: store, weather: weather)
            }
            Tab("My sky", systemImage: "sun.horizon", value: Section.mySky) {
                MySkyView(store: store, weather: weather)
            }
            Tab("People", systemImage: "person.2", value: Section.people) {
                PeopleListView(store: store, weather: weather)
            }
        }
    }

    enum Section: Hashable {
        case globe
        case mySky
        case people
    }
}
