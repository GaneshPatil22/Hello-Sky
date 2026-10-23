import SkyCore
import SkyData
import SwiftUI

/// Adds a person: find their city, name them, set their waking hours.
///
/// In that order on purpose. The city is what the rest depends on — it
/// suggests the name and decides the clock — so it is asked for first and the
/// keyboard moves on by itself once it is chosen.
struct AddPersonView: View {
    let store: PeopleStore

    @Environment(\.dismiss) private var dismiss
    @State private var model = AddPersonModel()
    @FocusState private var field: Field?

    private enum Field: Hashable {
        case city
        case name
    }

    var body: some View {
        NavigationStack {
            Form {
                whereSection
                if model.selectedCity != nil {
                    whoSection
                    awakeSection
                }
                if let failure = model.failure {
                    Section {
                        Label(failure, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .animation(.easeInOut(duration: Layout.reveal), value: model.selectedCity)
            .navigationTitle("Add someone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add)
                        .disabled(!model.canAdd)
                }
            }
            // Debounced: a search on every keystroke makes the list jump about
            // and asks far more of the network than it needs to.
            .task(id: model.query) {
                guard model.selectedCity == nil else { return }
                try? await Task.sleep(for: .milliseconds(Layout.debounceMilliseconds))
                guard !Task.isCancelled else { return }
                await model.search()
            }
            .onAppear { field = .city }
        }
        .presentationDetents([.large])
    }

    // MARK: - Where

    @ViewBuilder
    private var whereSection: some View {
        Section {
            if let city = model.selectedCity {
                HStack {
                    VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                        Text(city.name)
                        Text(city.country)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Change", action: changeCity)
                        .font(.subheadline)
                }
            } else {
                searchField
                ForEach(model.results) { city in
                    Button { choose(city) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                                Text(city.name)
                                Text(city.country)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                if model.results.isEmpty, model.hasSearched, !model.isSearching {
                    Text("No city by that name.")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Where they are")
        } footer: {
            if model.selectedCity == nil {
                Text("Their city decides the clock and the sky you will see.")
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: Layout.fieldSpacing) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search for a city", text: $model.query)
                .focused($field, equals: .city)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    if let first = model.results.first { choose(first) }
                }
            if model.isSearching {
                ProgressView().controlSize(.small)
            } else if !model.query.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") { model.query = "" }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.tertiary)
                    .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Who

    private var whoSection: some View {
        Section("Who they are") {
            TextField("Name", text: $model.name)
                .focused($field, equals: .name)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .onSubmit { if model.canAdd { add() } }

            VStack(alignment: .leading, spacing: Layout.avatarSpacing) {
                Text("Avatar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: avatarColumns, spacing: Layout.avatarSpacing) {
                    ForEach(AddPersonModel.avatarChoices, id: \.self) { emoji in
                        avatarButton(emoji)
                    }
                }
            }
            .padding(.vertical, Layout.rowSpacing)
        }
    }

    private func avatarButton(_ emoji: String) -> some View {
        let isChosen = emoji == model.avatarEmoji
        return Button {
            model.avatarEmoji = emoji
        } label: {
            Text(emoji)
                .font(.title3)
                .frame(width: Layout.avatar, height: Layout.avatar)
                .background(isChosen ? Color.accentColor.opacity(Layout.avatarChosen) : .clear,
                            in: .circle)
                .overlay {
                    Circle().strokeBorder(
                        isChosen ? Color.accentColor : .clear,
                        lineWidth: Layout.avatarBorder
                    )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Avatar \(emoji)")
        .accessibilityAddTraits(isChosen ? [.isButton, .isSelected] : .isButton)
    }

    private var avatarColumns: [GridItem] {
        [GridItem(.adaptive(minimum: Layout.avatar), spacing: Layout.avatarSpacing)]
    }

    // MARK: - Awake

    private var awakeSection: some View {
        Section {
            Picker("Awake from", selection: $model.awakeStart) {
                ForEach(AddPersonModel.hourChoices, id: \.self) { hour in
                    Text(AddPersonModel.hourLabel(hour)).tag(hour)
                }
            }
            Picker("Until", selection: $model.awakeEnd) {
                ForEach(AddPersonModel.hourChoices, id: \.self) { hour in
                    Text(AddPersonModel.hourLabel(hour)).tag(hour)
                }
            }
        } header: {
            Text("Usually awake")
        } footer: {
            Text(model.awakeSummary)
                .foregroundStyle(model.awakeHours.isValid ? Color.secondary : Color.red)
        }
    }

    // MARK: - Actions

    /// Picking a city puts the keyboard where it is next needed, rather than
    /// leaving it open over a list that has gone.
    private func choose(_ city: City) {
        model.select(city)
        field = model.trimmedName.isEmpty ? .name : nil
    }

    private func changeCity() {
        model.changeCity()
        field = .city
    }

    private func add() {
        field = nil
        if model.add(to: store) {
            dismiss()
        }
    }
}

extension AddPersonView {
    private enum Layout {
        static let rowSpacing: Double = 2
        static let fieldSpacing: Double = 8
        static let avatar: Double = 44
        static let avatarSpacing: Double = 8
        static let avatarChosen = 0.25
        static let avatarBorder: Double = 2
        static let reveal = 0.25
        static let debounceMilliseconds = 250
    }
}

#Preview {
    AddPersonView(store: try! PeopleStore(inMemory: true))
}
