import SkyCore
import SkyData
import SwiftUI

/// Adds a person: pick a city, give them a name, set their waking hours.
///
/// Plain by design; Phase 6 gives this a real sheet.
struct AddPersonView: View {
    let store: PeopleStore

    @Environment(\.dismiss) private var dismiss
    @State private var model = AddPersonModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Who") {
                    TextField("Name", text: $model.name)
                        .textInputAutocapitalization(.words)
                    Picker("Avatar", selection: $model.avatarEmoji) {
                        ForEach(AddPersonModel.avatarChoices, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }
                }

                Section("Where") {
                    if let city = model.selectedCity {
                        LabeledContent("City", value: city.qualifiedName)
                        Button("Choose a different city") { model.clearCity() }
                    } else {
                        ForEach(model.results) { city in
                            Button(city.qualifiedName) { model.select(city) }
                        }
                        if model.results.isEmpty, !model.query.isEmpty {
                            ContentUnavailableView.search(text: model.query)
                        }
                    }
                }

                Section("Usually awake") {
                    LabeledContent("From") {
                        Stepper(model.startLabel, value: $model.awakeStart, in: 0...23, step: 1)
                    }
                    LabeledContent("Until") {
                        Stepper(model.endLabel, value: $model.awakeEnd, in: 1...24, step: 1)
                    }
                }

                if let failure = model.failure {
                    Section { Text(failure).foregroundStyle(.red) }
                }
            }
            .searchable(text: $model.query, prompt: "Search for a city")
            .task(id: model.query) { await model.search() }
            .navigationTitle("Add Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { add() }
                        .disabled(!model.canAdd)
                }
            }
        }
    }

    private func add() {
        if model.add(to: store) {
            dismiss()
        }
    }
}

#Preview {
    AddPersonView(store: try! PeopleStore(inMemory: true))
}
