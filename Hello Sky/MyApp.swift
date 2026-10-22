import SwiftUI

@main
struct MyApp: App {
    @State private var startup = AppStartup()

    var body: some Scene {
        WindowGroup {
            RootView(startup: startup)
        }
    }
}
