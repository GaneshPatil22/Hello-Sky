import SwiftUI

struct RootView: View {
    let startup: AppStartup

    var body: some View {
        switch startup.state {
        case .ready(let store):
            HomeView(store: store, weather: startup.weather)
        case .failed(let reason):
            ContentUnavailableView(
                "Can't open your people",
                systemImage: "exclamationmark.triangle",
                description: Text(reason)
            )
        }
    }
}
