import Globe
import SkyCore
import SkyData
import SkyUI
import SwiftUI

struct ContentView: View {
    private let modulesLinked = GlobeModule.canReachDependencies() && SkyDataModule.canReachSkyCore()

    var body: some View {
        VStack(spacing: Layout.spacing) {
            Text("Hello Sky")
                .font(.largeTitle.weight(.light))
            Text(modulesLinked ? "All modules linked" : "Module wiring broken")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(Layout.padding)
    }
}

extension ContentView {
    private enum Layout {
        static let spacing: CGFloat = 8
        static let padding: CGFloat = 16
    }
}

#Preview {
    ContentView()
}
