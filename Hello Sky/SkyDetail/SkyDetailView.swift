import SkyCore
import SkyData
import SkyUI
import SwiftUI

/// Someone's sky, filling the screen.
///
/// The moment the app exists for: their real light, their local time, and
/// whether this is a good time to call. The sky is drawn live from the sun,
/// the moon and their weather — nothing here is a picture.
struct SkyDetailView: View {
    let person: Person
    /// Whose clock the comparisons are against, and where the arcs start.
    let home: Person?
    let weather: WeatherRepository
    @Bindable var time: TimeTravel
    @Bindable var settings: AppSettings
    /// Supplied when the sky is opened over the globe, so closing reverses the
    /// same move rather than dismissing a sheet.
    let onClose: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @Environment(\.locale) private var locale
    @State private var model: SkyDetailModel
    @State private var isChoosingLook = false
    @State private var reminder: SunReminder.Outcome?

    init(
        person: Person,
        home: Person?,
        weather: WeatherRepository,
        time: TimeTravel,
        settings: AppSettings,
        onClose: (() -> Void)? = nil
    ) {
        self.person = person
        self.home = home
        self.weather = weather
        self.time = time
        self.settings = settings
        self.onClose = onClose
        _model = State(wrappedValue: SkyDetailModel(place: person.place, repository: weather))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    sky(height: proxy.size.height * Layout.skyFraction)
                    details
                }
            }
            .scrollIndicators(.hidden)
            // On the scroll view, not around it: an inset applied outside only
            // shrinks the frame, leaving the slider floating over the content.
            .safeAreaInset(edge: .bottom) { slider }
        }
        .background(theme.sky.gradient(forSunElevation: SkyPalette.Elevation.deepNight).top.color)
        .task(id: hourKey) { await model.load(at: date) }
        .gesture(dismissDownwards)
        .sheet(isPresented: $isChoosingLook) {
            LookSheet(settings: settings)
                .presentationDetents([.height(LookSheet.preferredHeight)])
        }
        .alert("Reminder", isPresented: showingReminder) {
            Button("OK") { reminder = nil }
        } message: {
            Text(reminderMessage)
        }
    }

    // MARK: - Sky

    private func sky(height: Double) -> some View {
        ZStack(alignment: .top) {
            LiveSkyView(place: person.place, weather: model.weather, date: date)
                .frame(height: height)
                .clipped()
            VStack(spacing: Layout.headerGap) {
                header
                SkyHeadline(person: person, home: home, date: date, weather: model.weather)
            }
            .padding(.horizontal, Layout.padding)
            .padding(.top, Layout.topPadding)
        }
        .frame(height: height)
    }

    private var header: some View {
        ZStack {
            VStack(spacing: Layout.titleGap) {
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(person.place.city)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(Layout.subtitleOpacity))
            }
            HStack {
                circleButton("Back", systemImage: "chevron.left", action: close)
                Spacer()
                circleButton("Look", systemImage: "paintpalette") { isChoosingLook = true }
            }
        }
        .foregroundStyle(.white)
        .shadow(radius: Layout.shadow)
    }

    /// "Your sky" when it is yours; a possessive otherwise, which needs care
    /// for a name that already ends in s.
    private var title: String {
        guard person.id != home?.id else { return "Your sky" }
        let name = person.name
        return name.lowercased().hasSuffix("s") ? "\(name)' sky" : "\(name)'s sky"
    }

    private func circleButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.body.weight(.semibold))
            .frame(width: Layout.button, height: Layout.button)
            .panel(cornerRadius: Layout.button / 2)
    }

    // MARK: - Below the sky

    private var details: some View {
        VStack(spacing: Layout.cardGap) {
            SunArcCard(person: person, date: date)
            if let home, home.id != person.id {
                OverlapCard(home: home, person: person, date: date)
            }
            SkyActionsRow(
                card: card,
                shareTitle: SkyCard.title(for: person),
                reminderTitle: reminderButtonTitle,
                isReminderSet: isReminderSet,
                onRemind: scheduleReminder
            )
            Text(model.attribution.text)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Layout.padding)
    }

    private var slider: some View {
        TimeSlider(time: time, reference: home ?? person)
            .padding(.horizontal, Layout.padding)
            .padding(.bottom, Layout.padding)
    }

    // MARK: - Actions

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    private var dismissDownwards: some Gesture {
        DragGesture(minimumDistance: Layout.dismissDistance)
            .onEnded { value in
                if value.translation.height > Layout.dismissDistance { close() }
            }
    }

    private func scheduleReminder() {
        Task {
            reminder = await SunReminder.schedule(for: person, from: date)
        }
    }

    // MARK: - Derived

    private var date: Date { time.date() }

    /// Weather is hourly, so reloading is keyed to the hour rather than to
    /// `date`, which changes on every frame and would restart the task forever.
    private var hourKey: Int { Int(date.timeIntervalSince1970 / 3_600) }

    /// What gets shared. Describes the card rather than being one, so nothing
    /// is rendered until the share sheet asks for it.
    private var card: SkyCardTransfer {
        SkyCardTransfer(
            person: person,
            weather: model.weather,
            date: date,
            theme: theme,
            locale: locale
        )
    }

    private var nextEvent: SolarEvent? {
        Sun.solarDay(around: date, at: person.place.coordinate).next
    }

    private var reminderButtonTitle: String {
        guard let kind = nextEvent?.kind else { return "Remind me" }
        return kind == .sunrise ? "Remind me at sunrise" : "Remind me at sunset"
    }

    private var isReminderSet: Bool {
        if case .scheduled = reminder { return true }
        return false
    }

    private var showingReminder: Binding<Bool> {
        Binding(get: { reminder != nil }, set: { if !$0 { reminder = nil } })
    }

    private var reminderMessage: String {
        switch reminder {
        case .scheduled(let kind, let moment):
            guard let timeZone = person.place.timeZone else { return "Set." }
            var style = Date.FormatStyle.dateTime.hour().minute()
            style.timeZone = timeZone
            let name = kind == .sunrise ? "sunrise" : "sunset"
            return "You'll be told at \(name) in \(person.place.city), \(moment.formatted(style)) their time."
        case .noEvent:
            return "The sun neither rises nor sets in \(person.place.city) today."
        case .refused:
            return "Notifications are turned off for Hello Sky. You can turn them on in Settings."
        case .failed, .none:
            return "That reminder could not be set."
        }
    }
}

extension SkyDetailView {
    private enum Layout {
        static let skyFraction = 0.60
        static let padding: Double = 18
        static let topPadding: Double = 8
        static let headerGap: Double = 22
        static let titleGap: Double = 2
        static let cardGap: Double = 12
        static let button: Double = 40
        static let subtitleOpacity = 0.75
        static let shadow: Double = 8
        static let dismissDistance: Double = 60
    }
}
