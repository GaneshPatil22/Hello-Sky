import Foundation
import Observation
import SkyCore
import SwiftData

/// The people you follow, kept on this device.
///
/// Screens read `people`, which holds engine types rather than stored rows, so
/// nothing above this layer knows SwiftData is here.
@MainActor
@Observable
public final class PeopleStore {
    public private(set) var people: [Person] = []

    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    /// - Parameter inMemory: `true` for previews and tests, which should never
    ///   touch the real store or leave anything behind.
    public init(inMemory: Bool = false) throws {
        container = try ModelContainer(
            for: Schema(versionedSchema: PeopleSchemaV1.self),
            migrationPlan: PeopleMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
        )
        reload()
    }

    /// Builds a store on an explicit container, so a test can reopen one file twice.
    public init(container: ModelContainer) {
        self.container = container
        reload()
    }

    public var isFull: Bool {
        people.count >= Limits.maximumPeople
    }

    @discardableResult
    public func add(
        name: String,
        avatar: Avatar,
        city: City,
        awakeHours: AwakeHours = .default
    ) throws -> Person {
        guard !isFull else { throw PeopleStoreError.listIsFull(limit: Limits.maximumPeople) }
        guard awakeHours.isValid else { throw PeopleStoreError.invalidAwakeHours }
        guard !people.contains(where: { $0.place.id == city.id }) else {
            throw PeopleStoreError.alreadyAdded(name: city.name)
        }

        let person = Person(
            id: UUID().uuidString,
            name: name,
            avatar: avatar,
            place: city.place,
            awakeHours: awakeHours
        )
        context.insert(StoredPerson(person: person, sortOrder: nextSortOrder()))
        try save()
        return person
    }

    public func update(_ person: Person) throws {
        guard person.awakeHours.isValid else { throw PeopleStoreError.invalidAwakeHours }
        guard let stored = storedPerson(id: person.id) else { return }
        stored.update(from: person)
        try save()
    }

    public func remove(id: String) throws {
        guard let stored = storedPerson(id: id) else { return }
        context.delete(stored)
        try save()
    }

    public func removeAll() throws {
        for stored in allStored() {
            context.delete(stored)
        }
        try save()
    }

    /// Fills an empty store with the sample cast, for debug builds and previews.
    public func seedWithFixtures() throws {
        guard people.isEmpty else { return }
        for (index, person) in PersonFixtures.all.prefix(Limits.maximumPeople).enumerated() {
            context.insert(StoredPerson(person: person, sortOrder: index))
        }
        try save()
    }

    private func save() throws {
        try context.save()
        reload()
    }

    private func reload() {
        // Rows that cannot make a person are skipped rather than dropped from
        // the store: a future version may understand them.
        people = allStored().compactMap(\.person)
    }

    private func allStored() -> [StoredPerson] {
        let descriptor = FetchDescriptor<StoredPerson>(
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.name)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private func storedPerson(id: String) -> StoredPerson? {
        allStored().first { $0.id == id }
    }

    private func nextSortOrder() -> Int {
        (allStored().map(\.sortOrder).max() ?? -1) + 1
    }
}

extension PeopleStore {
    public enum Limits {
        /// v1 caps the list at ten, which keeps the globe readable.
        public static let maximumPeople = 10
    }
}
