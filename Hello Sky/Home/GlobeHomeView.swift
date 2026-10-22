import Globe
import SkyCore
import SkyData
import SkyUI
import SwiftUI

/// Home: the Earth, your people on it, and a slider across the day.
///
/// Also where the signature moment happens. Tapping someone turns the globe to
/// their city and opens their sky over it, so the two screens are one move
/// rather than two places.
struct GlobeHomeView: View {
    let store: PeopleStore
    let weather: WeatherRepository

    @State private var camera = GlobeCamera()
    @State private var transition = SkyTransition()
    @State private var focusProgress: Double = 0
    @State private var revealProgress: Double = 0
    @State private var revealOrigin: CGPoint?
    @State private var cameraBeforeFocus = GlobeCamera()
    @State private var isAddingPerson = false
    @State private var time = TimeTravel()

    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                globeLayer(in: proxy.size)
                if let person = openedPerson {
                    // The reveal has to cover the whole screen, bars included,
                    // so this layer ignores the safe area and the sky screen
                    // insets its own content instead.
                    skyLayer(for: person, in: proxy.size)
                }
            }
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top) { if !transition.isShowingSky { topBar } }
        .safeAreaInset(edge: .bottom) { if !transition.isShowingSky { bottomControls } }
        .sheet(isPresented: $isAddingPerson) {
            AddPersonView(store: store)
        }
        .toolbarVisibility(transition.isShowingSky ? .hidden : .automatic, for: .tabBar)
        .sensoryFeedback(.impact(weight: .light), trigger: transition.phase) { _, phase in
            // One tick when the sky lands, which is what makes it feel arrived at.
            phase == .sky(personID: transition.personID ?? "")
        }
    }

    // MARK: - Layers

    private func globeLayer(in size: CGSize) -> some View {
        ZStack {
            backdrop
            StarfieldView(tint: theme.starTint)
            GlobeSceneView(
                camera: displayCamera,
                date: date,
                isInteractive: !transition.isShowingSky,
                onCameraChange: { camera = $0 }
            )
            GlobeMarkerOverlay(
                people: store.people,
                camera: displayCamera,
                date: date,
                selected: openedPerson,
                onSelect: { open($0, in: size) }
            )
            // Faded against the reveal rather than switched off when the
            // move starts, which otherwise left the globe bare for half a
            // second before the sky arrived.
            .opacity(1 - revealProgress)
        }
    }

    private func skyLayer(for person: Person, in size: CGSize) -> some View {
        SkyDetailView(person: person, weather: weather, time: time, onClose: close)
            .modifier(CircularReveal(
                progress: revealProgress,
                origin: revealOrigin ?? CGPoint(x: size.width / 2, y: size.height / 2),
                isEnabled: !reduceMotion
            ))
    }

    /// Deep space behind the globe, taken from the look's darkest sky.
    private var backdrop: some View {
        theme.sky.gradient(forSunElevation: SkyPalette.Elevation.deepNight).linearGradient
    }

    private var topBar: some View {
        HStack {
            Text("Hello Sky")
                .font(.headline)
            Spacer()
            Button("Add Person", systemImage: "plus") { isAddingPerson = true }
                .disabled(store.isFull)
                .labelStyle(.iconOnly)
        }
        .padding(.horizontal, Layout.padding)
        .padding(.vertical, Layout.barPadding)
        .glassEffect(in: .rect(cornerRadius: Layout.barCorner))
        .padding(.horizontal, Layout.padding)
        .transition(.opacity)
    }

    private var bottomControls: some View {
        VStack(spacing: Layout.spacing) {
            if store.people.isEmpty {
                emptyPrompt
            } else {
                chips
            }
            TimeSlider(time: time)
        }
        .padding(Layout.padding)
        .transition(.opacity)
    }

    private var chips: some View {
        ScrollViewReader { scroller in
            ScrollView(.horizontal) {
                HStack(spacing: Layout.chipSpacing) {
                    ForEach(store.people) { person in
                        PersonChip(
                            person: person,
                            date: date,
                            isSelected: openedPerson?.id == person.id,
                            action: { open(person, in: nil) }
                        )
                        .id(person.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .onChange(of: openedPerson?.id) { _, id in
                guard let id else { return }
                withAnimation { scroller.scrollTo(id, anchor: .center) }
            }
        }
    }

    private var emptyPrompt: some View {
        Button("Add someone to see their sky", systemImage: "person.badge.plus") {
            isAddingPerson = true
        }
        .font(.subheadline)
        .padding(Layout.padding)
        .glassEffect(in: .rect(cornerRadius: Layout.barCorner))
    }

    // MARK: - The move

    /// Starts the turn-and-reveal.
    ///
    /// `size` is given when the tap came from a marker, so the circle can open
    /// from where the city actually is; a chip tap opens from the middle.
    private func open(_ person: Person, in size: CGSize?) {
        guard transition.open(personID: person.id) else { return }

        cameraBeforeFocus = camera
        focusProgress = 0
        revealProgress = 0
        revealOrigin = size.map { markerPoint(for: person, in: $0) }

        guard !reduceMotion else {
            // Reduce Motion gets a plain crossfade: no turn, no circle.
            withAnimation(.easeInOut(duration: SkyTransition.Timing.reveal)) { revealProgress = 1 }
            finishOpening(after: SkyTransition.Timing.reveal)
            return
        }

        withAnimation(.easeInOut(duration: SkyTransition.Timing.focus)) { focusProgress = 1 }
        withAnimation(.easeOut(duration: SkyTransition.Timing.reveal)
            .delay(SkyTransition.Timing.revealDelay)) { revealProgress = 1 }
        finishOpening(after: SkyTransition.Timing.total)
    }

    private func close() {
        guard transition.close() else { return }
        withAnimation(.easeIn(duration: SkyTransition.Timing.close)) {
            revealProgress = 0
            focusProgress = 0
        }
        Task {
            try? await Task.sleep(for: .seconds(SkyTransition.Timing.close))
            transition.finishClosing()
            camera = cameraBeforeFocus
        }
    }

    private func finishOpening(after delay: TimeInterval) {
        Task {
            try? await Task.sleep(for: .seconds(delay))
            transition.finishOpening()
        }
    }

    /// Where the city has ended up, so the circle opens from the right place.
    private func markerPoint(for person: Person, in size: CGSize) -> CGPoint {
        GlobeProjection.screenPoint(for: person.place.coordinate, camera: displayCamera, size: size)
            ?? CGPoint(x: size.width / 2, y: size.height / 2)
    }

    // MARK: - Derived

    private var openedPerson: Person? {
        transition.personID.flatMap { id in store.people.first { $0.id == id } }
    }

    /// The camera the globe is actually drawn with: the user's, or the turn
    /// towards the opened city while one is running.
    private var displayCamera: GlobeCamera {
        guard let person = openedPerson, focusProgress > 0 else { return camera }
        return cameraBeforeFocus.interpolated(
            towards: .focused(on: person.place.coordinate),
            progress: focusProgress
        )
    }

    private var date: Date { time.date() }
}

extension GlobeHomeView {
    private enum Layout {
        static let padding: Double = 16
        static let barPadding: Double = 10
        static let barCorner: Double = 22
        static let spacing: Double = 12
        static let chipSpacing: Double = 10
    }
}
