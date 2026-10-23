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
    @Bindable var settings: AppSettings
    /// Reported upward so the tab bar can step aside for a sky.
    @Binding var isSkyShowing: Bool

    /// Where the globe was last put by hand, and when. The camera on screen is
    /// worked out from these and the clock, so nothing writes state per frame.
    @State private var baseCamera = GlobeCamera()
    @State private var baseTime = Date.now
    @State private var dragAnchor: GlobeCamera?
    @State private var transition = SkyTransition()
    @State private var focusProgress: Double = 0
    @State private var revealProgress: Double = 0
    @State private var revealOrigin: CGPoint?
    @State private var cameraBeforeFocus = GlobeCamera()
    @State private var moveTask: Task<Void, Never>?
    @State private var isAddingPerson = false
    @State private var isChoosingLook = false
    @State private var isShowingSettings = false
    @State private var time = TimeTravel()
    @State private var started = Date.now

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
                    skyLayer(for: person, in: proxy.size, topInset: proxy.safeAreaInsets.top)
                }
            }
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top) { if !transition.isShowingSky { topBar } }
        .safeAreaInset(edge: .bottom) { if !transition.isShowingSky { bottomControls } }
        .sheet(isPresented: $isAddingPerson) {
            AddPersonView(store: store)
        }
        .sheet(isPresented: $isChoosingLook) {
            LookSheet(settings: settings)
                .presentationDetents([.height(LookSheet.preferredHeight)])
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsSheet(settings: settings, store: store, weather: weather)
                .presentationDetents([.medium])
        }
        .onChange(of: transition.isShowingSky) { _, showing in
            isSkyShowing = showing
        }
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
            VStack(spacing: 0) {
                Color.clear.frame(height: Layout.topReserve)
                // One timeline drives the Earth, the arcs and the markers, so
                // they are always drawn from the same instant and none of them
                // needs state written to it as the clock ticks.
                TimelineView(.animation(minimumInterval: Layout.frameInterval,
                                        paused: reduceMotion || transition.isShowingSky)) { context in
                    let live = liveCamera(at: context.date)
                    ZStack {
                        GlobeCanvasView(camera: live, date: date)
                            .gesture(spin)
                        GlobeArcsOverlay(
                            home: homePerson,
                            people: store.people,
                            camera: live,
                            elapsed: context.date.timeIntervalSince(started)
                        )
                        GlobeMarkerOverlay(
                            people: store.people,
                            camera: live,
                            date: date,
                            now: context.date,
                            selected: openedPerson,
                            onSelect: { open($0, in: globeSize(in: size)) }
                        )
                    }
                    .opacity(1 - revealProgress)
                }
                Color.clear.frame(height: Layout.controlsReserve)
            }
        }
    }

    /// The area the globe actually occupies, which is everything between the
    /// title and the controls.
    private func globeSize(in size: CGSize) -> CGSize {
        CGSize(
            width: size.width,
            height: max(size.height - Layout.controlsReserve - Layout.topReserve, 1)
        )
    }

    /// Turning the globe by hand. Writes the camera only when a finger moves
    /// it, never on a timer.
    private var spin: some Gesture {
        DragGesture()
            .onChanged { value in
                let anchor = dragAnchor ?? liveCamera(at: .now)
                dragAnchor = anchor
                var moved = anchor
                moved.drag(by: (
                    longitude: -value.translation.width * Layout.degreesPerPoint,
                    latitude: value.translation.height * Layout.degreesPerPoint
                ))
                baseCamera = moved
                baseTime = .now
            }
            .onEnded { value in
                dragAnchor = nil
                var released = baseCamera
                released.release(velocity: -value.velocity.width * Layout.degreesPerPoint)
                baseCamera = released
                baseTime = .now
            }
    }

    /// The camera to draw with: held still under a finger, carried by the
    /// transition while one is running, and drifting the rest of the time.
    private func liveCamera(at now: Date) -> GlobeCamera {
        if let person = openedPerson, focusProgress > 0 {
            return cameraBeforeFocus.interpolated(
                towards: .focused(on: person.place.coordinate),
                progress: focusProgress
            )
        }
        if dragAnchor != nil { return baseCamera }
        return baseCamera.projected(after: now.timeIntervalSince(baseTime))
    }

    private func skyLayer(for person: Person, in size: CGSize, topInset: Double) -> some View {
        SkyDetailView(person: person, home: homePerson, weather: weather, time: time,
                      settings: settings, onClose: close, topInset: topInset)
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
        HomeTopBar(
            canAddPerson: !store.isFull,
            onAddPerson: { isAddingPerson = true },
            onChooseLook: { isChoosingLook = true },
            onOpenSettings: { isShowingSettings = true }
        )
        .padding(.vertical, Layout.barPadding)
        .transition(.opacity)
    }

    private var bottomControls: some View {
        VStack(spacing: Layout.spacing) {
            TimeSlider(time: time, reference: homePerson)
            peopleRow
        }
        .padding(.horizontal, Layout.padding)
        .padding(.bottom, Layout.padding)
        .transition(.opacity)
    }

    private var peopleRow: some View {
        ScrollViewReader { scroller in
            ScrollView(.horizontal) {
                HStack(spacing: Layout.chipSpacing) {
                    ForEach(store.people) { person in
                        PersonChip(
                            person: person,
                            date: date,
                            isSelected: openedPerson?.id == person.id,
                            isHome: person.id == homePerson?.id,
                            action: { open(person, in: nil) }
                        )
                        .id(person.id)
                    }
                    AddPersonCard(
                        isFull: store.isFull,
                        limit: PeopleStore.Limits.maximumPeople
                    ) {
                        isAddingPerson = true
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

    // MARK: - The move

    /// Starts the turn-and-reveal.
    ///
    /// `size` is given when the tap came from a marker, so the circle can open
    /// from where the city actually is; a chip tap opens from the middle.
    private func open(_ person: Person, in size: CGSize?) {
        guard transition.open(personID: person.id) else { return }

        cameraBeforeFocus = liveCamera(at: .now)
        focusProgress = 0
        revealProgress = 0
        revealOrigin = size.map { markerPoint(for: person, in: $0) }

        guard !reduceMotion else {
            // Reduce Motion gets a plain crossfade: no turn, no circle.
            moveTask?.cancel()
            moveTask = Tween.run(duration: SkyTransition.Timing.reveal) { revealProgress = $0 }
            finishOpening(after: SkyTransition.Timing.reveal)
            return
        }

        // One tween drives the turn and the reveal together. They used to be
        // two separate animations, and because the globe is drawn in a canvas
        // it jumped to the end while the markers slid after it.
        moveTask?.cancel()
        moveTask = Tween.run(duration: SkyTransition.Timing.total) { progress in
            let elapsed = progress * SkyTransition.Timing.total
            focusProgress = Tween.eased(min(elapsed / SkyTransition.Timing.focus, 1))
            let intoReveal = elapsed - SkyTransition.Timing.revealDelay
            revealProgress = Tween.eased(
                (intoReveal / SkyTransition.Timing.reveal).clamped(to: 0...1)
            )
        }
        finishOpening(after: SkyTransition.Timing.total)
    }

    private func close() {
        guard transition.close() else { return }
        let fromReveal = revealProgress
        let fromFocus = focusProgress
        moveTask?.cancel()
        moveTask = Tween.run(duration: SkyTransition.Timing.close) { progress in
            revealProgress = fromReveal * (1 - progress)
            focusProgress = fromFocus * (1 - progress)
        }
        Task {
            try? await Task.sleep(for: .seconds(SkyTransition.Timing.close))
            transition.finishClosing()
            baseCamera = cameraBeforeFocus
            baseTime = .now
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
        let fallback = CGPoint(x: size.width / 2, y: size.height / 2)
        let local = GlobeProjection.screenPoint(
            for: person.place.coordinate, camera: liveCamera(at: .now), size: size
        ) ?? fallback
        // The globe sits below the title, so its own coordinates are that far
        // down the screen the reveal is masked in.
        return CGPoint(x: local.x, y: local.y + Layout.topReserve)
    }

    // MARK: - Derived

    /// The person every arc starts from, and whose clock the time card reads.
    private var homePerson: Person? {
        if let id = settings.homePersonID, let match = store.people.first(where: { $0.id == id }) {
            return match
        }
        return store.people.first
    }

    private var openedPerson: Person? {
        transition.personID.flatMap { id in store.people.first { $0.id == id } }
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
        static let disabled = 0.4
        static let frameInterval = 1.0 / 60
        /// How far a drag turns the globe.
        static let degreesPerPoint = 0.35
        /// Height kept free at the bottom for the chips and the time card.
        static let controlsReserve: Double = 300
        /// Height kept free at the top for the status bar and the title.
        static let topReserve: Double = 92
    }
}
