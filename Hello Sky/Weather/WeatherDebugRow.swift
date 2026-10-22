import SkyCore
import SkyData
import SwiftUI

/// One person's reading, with its provenance spelled out.
struct WeatherDebugRow: View {
    let row: WeatherDebugModel.Row

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            LabeledContent(row.person.name, value: row.person.place.city)
            LabeledContent("Condition") {
                Text(row.weather.condition.label)
            }
            LabeledContent("Cloud", value: row.weather.cloudCover.total, format: .percent.precision(.fractionLength(0)))
            LabeledContent("Rain", value: row.weather.rain, format: .percent.precision(.fractionLength(0)))
            if let temperature = row.weather.temperature {
                LabeledContent("Temperature", value: temperature.formatted(.measurement(width: .abbreviated)))
            } else {
                LabeledContent("Temperature", value: "unknown")
            }
            LabeledContent("Source", value: originLabel)
            Text(row.attribution.text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var originLabel: String {
        switch row.weather.origin {
        case .live: "live"
        case .cache: "cache"
        case .estimated: "estimated"
        }
    }
}

extension WeatherDebugRow {
    private enum Layout {
        static let spacing: Double = 4
    }
}
