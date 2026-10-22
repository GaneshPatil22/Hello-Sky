import SkyData
import SkyUI
import SwiftUI

/// The app's three places: the globe, your own sky, and the people list.
struct HomeView: View {
    let store: PeopleStore
    let weather: WeatherRepository
    @Bindable var settings: AppSettings

    @State private var tab: Section = .globe
    @Environment(\.themeRegistry) private var registry

    var body: some View {
        TabView(selection: $tab) {
            Tab("Globe", systemImage: "globe", value: Section.globe) {
                GlobeHomeView(store: store, weather: weather, settings: settings)
            }
            Tab("My sky", systemImage: "sun.max", value: Section.mySky) {
                MySkyView(store: store, weather: weather, settings: settings)
            }
            Tab("People", systemImage: "square.grid.2x2", value: Section.people) {
                PeopleListView(store: store, weather: weather)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        // The look applies to every screen at once, which is what makes it a
        // look rather than a per-screen setting.
        .theme(registry.theme(storedID: settings.themeID))
        .preferredColorScheme(.dark)
    }

    enum Section: Hashable {
        case globe
        case mySky
        case people
    }
}
