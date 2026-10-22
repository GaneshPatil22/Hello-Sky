import SkyCore
import SwiftUI

/// A contact sheet of skies: times down, weather across, one look at a time.
///
/// How the renderer gets judged. Looking at one sky tells you little; seeing
/// twenty-four side by side shows immediately where a gradient goes wrong.
public struct SkyGalleryView: View {
    @State private var placeIndex = 0
    @State private var themeID = ThemeRegistry.standard.defaultTheme.id

    @Environment(\.themeRegistry) private var registry

    public init() {}

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Layout.rowSpacing) {
                ForEach(SkyGalleryCase.cases(for: place, weather: SkyWeather.Samples.clear()), id: \.id) { moment in
                    SkyGalleryRow(moment: moment, theme: theme)
                }
            }
            .padding(Layout.padding)
        }
        .safeAreaInset(edge: .top) {
            controls
        }
        .navigationTitle("Sky gallery")
    }

    private var controls: some View {
        VStack {
            Picker("City", selection: $placeIndex) {
                ForEach(SkyGalleryCase.places.indices, id: \.self) { index in
                    Text(SkyGalleryCase.places[index].city).tag(index)
                }
            }
            .pickerStyle(.segmented)

            Picker("Look", selection: $themeID) {
                ForEach(registry.themes) { option in
                    Text(option.name).tag(option.id)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(Layout.padding)
        .background(.bar)
    }

    private var place: Place {
        SkyGalleryCase.places[placeIndex]
    }

    private var theme: Theme {
        registry.theme(storedID: themeID)
    }
}

extension SkyGalleryView {
    private enum Layout {
        static let rowSpacing: Double = 16
        static let padding: Double = 12
    }
}

#Preview {
    NavigationStack { SkyGalleryView() }
}
