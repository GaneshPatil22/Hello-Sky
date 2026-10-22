import SkyCore
import SkyData
import SwiftUI

/// Every person's weather on one screen, with where each reading came from.
///
/// A development tool, not a feature: it is how the live, cache, and estimate
/// paths get watched without turning the network off and guessing.
struct WeatherDebugView: View {
    let people: [Person]
    @State private var model: WeatherDebugModel

    init(people: [Person], repository: WeatherRepository) {
        self.people = people
        _model = State(wrappedValue: WeatherDebugModel(repository: repository))
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Calls used today", value: model.callsUsed, format: .number)
            }
            ForEach(model.rows) { row in
                WeatherDebugRow(row: row)
            }
        }
        .overlay {
            if model.rows.isEmpty, model.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Weather")
        .task { await model.load(people: people) }
        .refreshable { await model.load(people: people) }
    }
}
