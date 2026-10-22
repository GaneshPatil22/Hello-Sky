import SkyCore
import SkyData
import SkyUI
import SwiftUI

/// One live sky with a slider across the next day.
///
/// The check the phase turns on: dragging the slider has to move the sky
/// smoothly, with no jump as the sun crosses the horizon.
struct SkySliderView: View {
    let people: [Person]

    @State private var personIndex = 0
    @State private var hoursFromNow = 0.0
    @State private var themeID = ThemeRegistry.standard.defaultTheme.id

    @Environment(\.themeRegistry) private var registry

    var body: some View {
        VStack(spacing: Layout.spacing) {
            if let person {
                LiveSkyView(place: person.place, weather: weather, date: date)
                    .clipShape(.rect(cornerRadius: Layout.cornerRadius))
                    .theme(theme)
                    .overlay(alignment: .topLeading) { caption(for: person) }
            } else {
                ContentUnavailableView("No one to show", systemImage: "person.2")
            }
            controls
        }
        .padding(Layout.padding)
        .navigationTitle("Sky")
    }

    private func caption(for person: Person) -> some View {
        VStack(alignment: .leading) {
            Text(person.place.city)
                .font(.title2)
            if let timeZone = person.place.timeZone {
                Text(date, format: clockFormat(in: timeZone))
                    .font(.largeTitle.weight(.light))
                    .monospacedDigit()
            }
        }
        .foregroundStyle(.white)
        .shadow(radius: Layout.captionShadow)
        .padding(Layout.padding)
    }

    private var controls: some View {
        VStack {
            Picker("Person", selection: $personIndex) {
                ForEach(people.indices, id: \.self) { index in
                    Text(people[index].name).tag(index)
                }
            }
            .pickerStyle(.menu)

            Picker("Look", selection: $themeID) {
                ForEach(registry.themes) { option in
                    Text(option.name).tag(option.id)
                }
            }
            .pickerStyle(.segmented)

            LabeledContent(hoursLabel) {
                Slider(value: $hoursFromNow, in: TimeRange.hours, step: TimeRange.step)
            }
        }
    }

    private var person: Person? {
        people.indices.contains(personIndex) ? people[personIndex] : nil
    }

    private var date: Date {
        Date.now.addingTimeInterval(hoursFromNow * 3_600)
    }

    private var theme: Theme {
        registry.theme(storedID: themeID)
    }

    /// Sample weather for now; Phase 6 joins this to the repository.
    private var weather: SkyWeather {
        SkyWeather.Samples.partlyCloudy(at: date)
    }

    private var hoursLabel: String {
        hoursFromNow == 0 ? "Now" : "\(Int(hoursFromNow)) h"
    }

    private func clockFormat(in timeZone: TimeZone) -> Date.FormatStyle {
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        return style
    }
}

extension SkySliderView {
    private enum Layout {
        static let spacing: Double = 16
        static let padding: Double = 12
        static let cornerRadius: Double = 16
        static let captionShadow: Double = 8
    }

    /// Not named `Slider`: that would shadow SwiftUI's own control.
    private enum TimeRange {
        static let hours: ClosedRange<Double> = -12...24
        static let step: Double = 0.25
    }
}
