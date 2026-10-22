import Globe
import SkyCore
import SkyData
import SkyUI
import SwiftUI

/// Home: the Earth, your people on it, and a slider across the day.
///
/// Follows the prototype's layout — globe filling the screen, a glass bar on
/// top, chips along the bottom — built from native materials rather than its
/// stylesheet.
struct GlobeHomeView: View {
    let store: PeopleStore
    let weather: WeatherRepository

    @State private var camera = GlobeCamera()
    @State private var selected: Person?
    @State private var isAddingPerson = false
    @State private var time = TimeTravel()

    @Environment(\.theme) private var theme

    var body: some View {
        ZStack {
            backdrop
            StarfieldView(tint: theme.starTint)
            GlobeSceneView(camera: $camera, date: date)
            GlobeMarkerOverlay(
                people: store.people,
                camera: camera,
                date: date,
                selected: selected,
                onSelect: { selected = $0 }
            )
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) { topBar }
        .safeAreaInset(edge: .bottom) { bottomControls }
        .fullScreenCover(item: $selected) { person in
            SkyDetailView(person: person, weather: weather, time: time)
        }
        .sheet(isPresented: $isAddingPerson) {
            AddPersonView(store: store)
        }
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
    }

    private var chips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Layout.chipSpacing) {
                ForEach(store.people) { person in
                    PersonChip(
                        person: person,
                        date: date,
                        isSelected: selected?.id == person.id,
                        action: { selected = person }
                    )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
    }

    private var emptyPrompt: some View {
        Button("Add someone to see their sky", systemImage: "person.badge.plus") {
            isAddingPerson = true
        }
        .font(.subheadline)
        .padding(Layout.padding)
        .glassEffect(in: .rect(cornerRadius: Layout.barCorner))
    }

    private var date: Date {
        time.date()
    }
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
