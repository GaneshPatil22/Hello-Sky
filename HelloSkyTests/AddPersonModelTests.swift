import Foundation
import SkyCore
import SkyData
import Testing

@testable import Hello_Sky

@MainActor
@Suite("Add person")
struct AddPersonModelTests {
    private func makeModel() -> AddPersonModel {
        // The catalogue, not MapKit: tests must not depend on the network.
        AddPersonModel(search: CatalogCitySearch())
    }

    private func tokyo() -> City {
        CityCatalog.cities(matching: "Tokyo").first { $0.name == "Tokyo" }!
    }

    @Test("Cannot add anyone until a city is chosen")
    func needsACity() {
        let model = makeModel()
        model.name = "Kenji"
        #expect(!model.canAdd)

        model.select(tokyo())
        #expect(model.canAdd)
    }

    @Test("Says what is still missing")
    func explainsWhatIsMissing() {
        let model = makeModel()
        #expect(model.blocker == "Choose a city first.")

        model.select(tokyo())
        model.name = "  "
        #expect(model.blocker == "Give them a name.")

        model.name = "Kenji"
        #expect(model.blocker == nil)

        model.awakeStart = 22
        model.awakeEnd = 6
        #expect(model.blocker?.contains("start before") == true)
    }

    @Test("Summarises how long they are awake")
    func summarisesAwakeHours() {
        let model = makeModel()
        model.awakeStart = 8
        model.awakeEnd = 23
        #expect(model.awakeSummary == "Awake for 15 hours")

        model.awakeEnd = 6
        #expect(model.awakeSummary == "That is not a day.")
    }

    @Test("Changing the city goes back to searching with the text intact")
    func changingCityKeepsTheText() {
        let model = makeModel()
        model.select(tokyo())
        #expect(model.query == tokyo().qualifiedName)

        model.changeCity()
        #expect(model.selectedCity == nil)
        #expect(model.query == tokyo().qualifiedName, "the text should still be there to edit")
    }

    @Test("An empty search clears the results rather than searching for nothing")
    func emptyQueryClears() async {
        let model = makeModel()
        model.query = "Tokyo"
        await model.search()
        #expect(!model.results.isEmpty)

        model.query = "   "
        await model.search()
        #expect(model.results.isEmpty)
        #expect(!model.hasSearched)
    }

    @Test("Reports when a search found nothing, but not before it has run")
    func reportsEmptyResults() async {
        let model = makeModel()
        #expect(!model.hasSearched, "nothing should be reported before a search")

        model.query = "Zzzyxborough"
        await model.search()
        #expect(model.hasSearched)
        #expect(model.results.isEmpty)
    }

    @Test("Choosing a city leaves the name alone")
    func cityLeavesTheName() {
        let model = makeModel()
        model.select(tokyo())
        #expect(model.name.isEmpty, "the city must not stand in for a person's name")

        let named = makeModel()
        named.name = "Kenji"
        named.select(tokyo())
        #expect(named.name == "Kenji", "a name already typed must not be overwritten")
    }

    @Test("A name of only spaces is not a name")
    func blankNameIsRefused() {
        let model = makeModel()
        model.select(tokyo())
        model.name = "   "
        #expect(!model.canAdd)
    }

    @Test("Waking hours that do not describe a day are refused")
    func backwardsHoursAreRefused() {
        let model = makeModel()
        model.select(tokyo())
        model.name = "Kenji"
        model.awakeStart = 22
        model.awakeEnd = 6
        #expect(!model.canAdd)
    }

    @Test("Searching finds a city through the seam")
    func searchFindsCities() async {
        let model = makeModel()
        model.query = "Tokyo"
        await model.search()
        #expect(model.results.contains { $0.name == "Tokyo" })
    }

    @Test("Adds the person to the store")
    func addsToTheStore() throws {
        let store = try PeopleStore(inMemory: true)
        let model = makeModel()
        model.select(tokyo())
        model.name = "Kenji"

        #expect(model.add(to: store))
        #expect(store.people.count == 1)
        #expect(store.people.first?.place.city == "Tokyo")
        #expect(model.failure == nil)
    }

    @Test("Explains itself when the same city is added twice")
    func explainsDuplicates() throws {
        let store = try PeopleStore(inMemory: true)
        let first = makeModel()
        first.select(tokyo())
        first.name = "Kenji"
        #expect(first.add(to: store))

        let second = makeModel()
        second.select(tokyo())
        second.name = "Someone else"
        #expect(!second.add(to: store))
        #expect(second.failure?.contains("Tokyo") == true, "got \(second.failure ?? "nothing")")
    }

    @Test("Explains itself when the list is full")
    func explainsAFullList() throws {
        let store = try PeopleStore(inMemory: true)
        for city in CityCatalog.all.prefix(PeopleStore.Limits.maximumPeople) {
            try store.add(name: city.name, avatar: .emoji("🙂"), city: city)
        }
        let model = makeModel()
        model.select(tokyo())
        model.name = "One too many"

        #expect(!model.add(to: store))
        #expect(model.failure?.contains("\(PeopleStore.Limits.maximumPeople)") == true)
    }
}
