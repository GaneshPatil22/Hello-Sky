import SkyCore
import SkyData
import SwiftUI

/// The few things worth remembering, and the choice of whose globe this is.
struct SettingsSheet: View {
    @Bindable var settings: AppSettings
    let store: PeopleStore
    let weather: WeatherRepository

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Home", selection: homeSelection) {
                        ForEach(store.people) { person in
                            Text("\(person.name) — \(person.place.city)").tag(person.id)
                        }
                    }
                } header: {
                    Text("Home")
                } footer: {
                    Text("Every arc on the globe starts from here, and the clock reads from this city.")
                }

                Section {
                    Toggle("24-hour time", isOn: $settings.usesTwentyFourHourTime)
                    Toggle("Temperatures in °F", isOn: $settings.usesFahrenheit)
                    Toggle("Reduce motion", isOn: $settings.prefersReducedMotion)
                }

                Section {
                    NavigationLink("About and credits") {
                        AboutView(weather: weather)
                    }
                }

                #if DEBUG
                Section {
                    LabeledContent("Demo data", value: "People are sample values")
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Falls back to the first person, which is what the globe does when no
    /// home has been chosen yet.
    private var homeSelection: Binding<String> {
        Binding(
            get: { settings.homePersonID ?? store.people.first?.id ?? "" },
            set: { settings.homePersonID = $0 }
        )
    }
}
