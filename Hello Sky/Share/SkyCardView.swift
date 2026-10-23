import SkyCore
import SkyUI
import SwiftUI

/// The sky as a card to send someone.
///
/// Laid out at a fixed size rather than filling a screen: it is rendered to an
/// image, so it has to look the same whatever device made it.
struct SkyCardView: View {
    let person: Person
    let weather: SkyWeather
    let date: Date
    let theme: Theme

    /// Portrait, in the proportions a story expects.
    static let size = CGSize(width: 360, height: 640)

    @Environment(\.locale) private var locale

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SkyView(snapshot: snapshot)
            VStack(alignment: .leading, spacing: Layout.spacing) {
                Text(timeText)
                    .font(.system(size: Layout.clock, weight: .thin, design: .rounded))
                    .monospacedDigit()
                Text(person.place.city)
                    .font(.title3.weight(.medium))
                Text(caption)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(Layout.captionOpacity))
            }
            .foregroundStyle(.white)
            .shadow(radius: Layout.shadow)
            .padding(Layout.padding)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .clipShape(.rect(cornerRadius: Layout.corner))
    }

    private var snapshot: SkySnapshot {
        SkySnapshot(place: person.place, date: date, weather: weather, theme: theme)
    }

    private var timeText: String {
        guard let timeZone = person.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return date.formatted(style)
    }

    /// "Clear at Kenji's" — the sky, and whose it is.
    private var caption: String {
        let sky = String(localized: weather.condition.label)
        return "\(sky) at \(person.name)'s"
    }
}

extension SkyCardView {
    private enum Layout {
        static let padding: Double = 24
        static let spacing: Double = 4
        static let clock: Double = 56
        static let captionOpacity = 0.85
        static let shadow: Double = 8
        static let corner: Double = 28
    }
}
