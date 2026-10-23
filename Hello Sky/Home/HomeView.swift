import SkyData
import SkyUI
import SwiftUI

/// The app's three places: the globe, your own sky, and the people list.
struct HomeView: View {
    let store: PeopleStore
    let weather: WeatherRepository
    @Bindable var settings: AppSettings

    @State private var tab: Section = .globe
    /// Set while a sky fills the screen, so the bar gets out of its way.
    @State private var isTabBarHidden = false

    @Environment(\.themeRegistry) private var registry

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .safeAreaInset(edge: .bottom) {
                    // Keeps each screen's own controls clear of the bar.
                    Color.clear.frame(height: isTabBarHidden ? 0 : AppTabBar.height)
                }
            if !isTabBarHidden {
                AppTabBar(selection: $tab)
                    .transition(.opacity)
            }
        }
        // The bar is not pushed under the home indicator: letting it sit above
        // is what makes a plain height inset enough to keep content clear of it.
        // The look applies to every screen at once, which is what makes it a
        // look rather than a per-screen setting.
        .theme(registry.theme(storedID: settings.themeID))
        .preferredColorScheme(.dark)
        // Rounded everywhere. The default face is flat beside a drawn sky, and
        // this is the one the clock already used.
        .fontDesign(.rounded)
        .animation(.easeInOut(duration: Animation.barFade), value: isTabBarHidden)
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .globe:
            GlobeHomeView(
                store: store,
                weather: weather,
                settings: settings,
                isSkyShowing: $isTabBarHidden
            )
        case .mySky:
            MySkyView(store: store, weather: weather, settings: settings)
        case .people:
            PeopleListView(store: store, weather: weather)
        }
    }

    enum Section: Hashable, CaseIterable {
        case globe
        case mySky
        case people

        var title: String {
            switch self {
            case .globe: "Globe"
            case .mySky: "My sky"
            case .people: "People"
            }
        }

        var symbol: String {
            switch self {
            case .globe: "globe"
            case .mySky: "sun.max"
            case .people: "square.grid.2x2"
            }
        }
    }
}

extension HomeView {
    private enum Animation {
        static let barFade = 0.25
    }
}
