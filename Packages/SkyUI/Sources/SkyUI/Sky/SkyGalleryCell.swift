import SkyCore
import SwiftUI

/// One sky in the gallery, still rather than animated so the sheet stays cheap.
struct SkyGalleryCell: View {
    let moment: SkyGalleryCase
    let weather: SkyWeather
    let theme: Theme

    var body: some View {
        VStack(spacing: Layout.spacing) {
            SkyView(snapshot: snapshot)
                .frame(width: Layout.width, height: Layout.height)
                .clipShape(.rect(cornerRadius: Layout.cornerRadius))
            Text(weather.condition.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var snapshot: SkySnapshot {
        SkySnapshot(place: moment.place, date: moment.date, weather: weather, theme: theme)
    }
}

extension SkyGalleryCell {
    private enum Layout {
        static let width: Double = 140
        static let height: Double = 200
        static let cornerRadius: Double = 12
        static let spacing: Double = 4
    }
}
