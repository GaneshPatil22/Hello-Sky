import SkyCore
import SkyData
import SkyUI
import SwiftUI

/// Someone's sky, filling the screen.
///
/// The moment the app exists for: their real light, their local time, and
/// whether this is a good time to call. Swipe down to go back to the globe.
struct SkyDetailView: View {
    let person: Person
    let weather: WeatherRepository
    @Bindable var time: TimeTravel
    /// Supplied when the sky is opened over the globe, so closing reverses the
    /// same move rather than dismissing a sheet.
    let onClose: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @Environment(\.locale) private var locale
    @State private var model: SkyDetailModel

    init(person: Person, weather: WeatherRepository, time: TimeTravel, onClose: (() -> Void)? = nil) {
        self.person = person
        self.weather = weather
        self.time = time
        self.onClose = onClose
        _model = State(wrappedValue: SkyDetailModel(place: person.place, repository: weather))
    }

    var body: some View {
        ZStack {
            LiveSkyView(place: person.place, weather: model.weather, date: date)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: Layout.spacing) {
                header
                Spacer()
                SkyFactsCard(person: person, weather: model.weather, date: date)
                TimeSlider(time: time, reference: person)
                Text(model.attribution.text)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(Layout.creditOpacity))
            }
            .padding(Layout.padding)
            // The layer under this ignores the safe area so the reveal can
            // cover the bars; the content puts its own inset back.
            .safeAreaPadding()
        }
        .task(id: hourKey) { await model.load(at: date) }
        .gesture(dismissDownwards)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Layout.headerSpacing) {
            HStack {
                Text(person.name)
                    .font(.title3.weight(.medium))
                Spacer()
                Button("Close", systemImage: "chevron.down", action: close)
                    .labelStyle(.iconOnly)
                    .padding(Layout.closePadding)
                    .glassEffect(in: .circle)
            }
            Text(timeText)
                .font(.system(size: Layout.clockSize, weight: .thin, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(Layout.clockMinimumScale)
                .lineLimit(1)
            Text(sentence)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(Layout.sentenceOpacity))
        }
        .foregroundStyle(.white)
        .shadow(radius: Layout.shadow)
    }

    private var dismissDownwards: some Gesture {
        DragGesture(minimumDistance: Layout.dismissDistance)
            .onEnded { value in
                if value.translation.height > Layout.dismissDistance { close() }
            }
    }

    private func close() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    private var date: Date { time.date() }

    /// Weather is hourly, so reloading is keyed to the hour rather than to
    /// `date`, which changes on every frame and would restart the task forever.
    private var hourKey: Int { Int(date.timeIntervalSince1970 / 3_600) }

    private var timeText: String {
        guard let timeZone = person.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return date.formatted(style)
    }

    /// The one-line status from the prototype: time, sky, and whether to call.
    private var sentence: String {
        let status = CallStatus.status(for: person, at: date)
        let sky = String(localized: model.weather.condition.label).lowercased()
        return "\(person.place.city), \(sky). \(StatusDot.sentence(for: status))."
    }
}

extension SkyDetailView {
    private enum Layout {
        static let padding: Double = 20
        static let spacing: Double = 16
        static let headerSpacing: Double = 6
        static let clockSize: Double = 72
        static let clockMinimumScale = 0.5
        static let sentenceOpacity = 0.8
        static let creditOpacity = 0.55
        static let shadow: Double = 10
        static let closePadding: Double = 10
        static let dismissDistance: Double = 60
    }
}
