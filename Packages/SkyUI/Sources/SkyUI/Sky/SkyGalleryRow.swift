import SkyCore
import SwiftUI

/// One moment of the gallery, with every weather type side by side.
struct SkyGalleryRow: View {
    let moment: SkyGalleryCase
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.labelSpacing) {
            Text(moment.label)
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal) {
                HStack(spacing: Layout.cellSpacing) {
                    ForEach(SkyWeather.Samples.all(at: moment.date), id: \.condition) { weather in
                        SkyGalleryCell(moment: moment, weather: weather, theme: theme)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

extension SkyGalleryRow {
    private enum Layout {
        static let labelSpacing: Double = 4
        static let cellSpacing: Double = 8
    }
}
