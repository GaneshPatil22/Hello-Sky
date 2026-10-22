import SkyCore
import SwiftUI

/// The glass card over the sky: temperature, cloud, and the next sun event.
struct SkyFactsCard: View {
    let person: Person
    let weather: SkyWeather
    let date: Date

    var body: some View {
        HStack(spacing: Layout.spacing) {
            ForEach(facts, id: \.label) { fact in
                VStack(alignment: .leading, spacing: Layout.factSpacing) {
                    Text(fact.label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(fact.value)
                        .font(.subheadline.weight(.medium))
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(Layout.padding)
        .glassEffect(in: .rect(cornerRadius: Layout.corner))
    }

    private var facts: [(label: String, value: String)] {
        var rows: [(String, String)] = []
        if let temperature = weather.temperature {
            rows.append(("Temperature", temperature.formatted(.measurement(width: .narrow))))
        }
        rows.append(("Sky", String(localized: weather.condition.label)))
        if let event = nextEvent {
            rows.append((event.kind == .sunrise ? "Sunrise" : "Sunset", eventTime(event)))
        }
        return rows.map { (label: $0.0, value: $0.1) }
    }

    private var nextEvent: SolarEvent? {
        Sun.solarDay(around: date, at: person.place.coordinate).next
    }

    private func eventTime(_ event: SolarEvent) -> String {
        guard let timeZone = person.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        return event.date.formatted(style)
    }
}

extension SkyFactsCard {
    private enum Layout {
        static let spacing: Double = 16
        static let factSpacing: Double = 3
        static let padding: Double = 16
        static let corner: Double = 20
    }
}
