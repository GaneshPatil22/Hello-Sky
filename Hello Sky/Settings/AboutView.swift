import SkyData
import SwiftUI

/// What the app is, what it is built from, and what it does with your data.
///
/// The weather credit is read from the provider rather than written here, so
/// changing weather source changes this screen automatically and the app
/// cannot end up crediting a service it no longer uses.
struct AboutView: View {
    let weather: WeatherRepository

    @State private var weatherCredit: WeatherAttribution?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Layout.spacing) {
                    Text(Copy.name)
                        .font(.title2.weight(.bold))
                    Text(Copy.tagline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, Layout.rowPadding)
                LabeledContent("Version", value: Self.version)
            }

            Section("Weather") {
                if let weatherCredit {
                    if let url = weatherCredit.url {
                        Link(weatherCredit.text, destination: url)
                    } else {
                        Text(weatherCredit.text)
                    }
                }
                Text(Copy.weatherNote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Map data") {
                Link(Copy.naturalEarth, destination: Links.naturalEarth)
                Text(Copy.naturalEarthNote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Privacy") {
                Text(Copy.privacy)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            weatherCredit = await weather.providerAttribution
        }
    }

    static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(short) (\(build))"
    }
}

extension AboutView {
    private enum Copy {
        static let name = "Hello Sky"
        static let tagline = "The sky where the people you care about are, right now."
        static let weatherNote = """
            Weather is fetched for each city you follow. When it cannot be \
            reached, the app falls back to what it last saw, and then to a \
            clear sky worked out from the sun's position.
            """
        static let naturalEarth = "Coastlines from Natural Earth"
        static let naturalEarthNote = """
            The globe draws its continents from a land mask built from Natural \
            Earth's 1:50m land polygons, which are in the public domain.
            """
        static let privacy = """
            There are no accounts, no analytics, and no server of our own. The \
            people you follow are stored on this device. City coordinates are \
            sent to the weather service to get a forecast, and that is the only \
            thing that leaves the phone.
            """
    }

    private enum Links {
        static let naturalEarth = URL(string: "https://www.naturalearthdata.com/about/terms-of-use/")!
    }

    private enum Layout {
        static let spacing: Double = 4
        static let rowPadding: Double = 6
    }
}
