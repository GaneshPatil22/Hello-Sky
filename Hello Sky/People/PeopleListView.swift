import SkyCore
import SkyData
import SwiftUI

/// The plain list of people, their local time, and whether to call.
///
/// Deliberately unstyled: Phase 6 replaces this with the globe and the sky
/// screens. It exists to prove the store and the engine agree.
struct PeopleListView: View {
    let store: PeopleStore

    @State private var isAddingPerson = false
    @State private var isShowingFailure = false
    @State private var failureMessage = ""

    var body: some View {
        NavigationStack {
            // The timeline wraps the list rather than sitting inside it: a
            // TimelineView is one view, so a List would make all the people
            // into a single row and ignore swipe-to-delete.
            TimelineView(.periodic(from: .now, by: Refresh.interval)) { context in
                List {
                    if store.people.isEmpty {
                        ContentUnavailableView(
                            "No one yet",
                            systemImage: "person.2",
                            description: Text("Add someone to see the sky where they are.")
                        )
                    } else {
                        ForEach(store.people) { person in
                            PersonRow(person: person, date: context.date)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Person", systemImage: "plus") { isAddingPerson = true }
                        .disabled(store.isFull)
                }
            }
            .sheet(isPresented: $isAddingPerson) {
                AddPersonView(store: store)
            }
            .alert("Couldn't remove that person", isPresented: $isShowingFailure) {
                Button("OK") {}
            } message: {
                Text(failureMessage)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        do {
            for person in offsets.map({ store.people[$0] }) {
                try store.remove(id: person.id)
            }
        } catch {
            failureMessage = error.localizedDescription
            isShowingFailure = true
        }
    }
}

extension PeopleListView {
    private enum Refresh {
        /// Minute resolution is all a clock face needs, and it keeps the app asleep.
        static let interval: TimeInterval = 60
    }
}

#Preview {
    let store = try! PeopleStore(inMemory: true)
    try! store.seedWithFixtures()
    return PeopleListView(store: store)
}
