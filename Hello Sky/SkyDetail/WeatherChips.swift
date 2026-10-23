import SkyCore
import SwiftUI

/// Temperature, sky and cloud, as three small facts.
struct WeatherChips: View {
    let weather: SkyWeather

    var body: some View {
        HStack(spacing: Layout.spacing) {
            ForEach(chips, id: \.self) { chip in
                Text(chip)
                    .font(.subheadline)
                    .padding(.horizontal, Layout.paddingX)
                    .padding(.vertical, Layout.paddingY)
                    .panel(cornerRadius: Layout.corner)
            }
        }
        .foregroundStyle(.white)
    }

    private var chips: [String] {
        var found: [String] = []
        if let temperature = weather.temperature {
            found.append(temperature.formatted(.measurement(width: .narrow)))
        }
        found.append(String(localized: weather.condition.label))
        found.append(weather.cloudCover.total.formatted(.percent.precision(.fractionLength(0))) + " cloud")
        return found
    }
}

extension WeatherChips {
    private enum Layout {
        static let spacing: Double = 8
        static let paddingX: Double = 14
        static let paddingY: Double = 8
        static let corner: Double = 18
    }
}
