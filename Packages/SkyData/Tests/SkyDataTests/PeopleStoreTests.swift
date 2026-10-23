import Foundation
import SkyCore
import SwiftData
import Testing

@testable import SkyData

@MainActor
@Suite("People store")
struct PeopleStoreTests {
    private func emptyStore() throws -> PeopleStore {
        try PeopleStore(inMemory: true)
    }

    private func city(_ name: String) -> City {
        CityCatalog.cities(matching: name).first { $0.name == name }!
    }

    @Test("Starts empty")
    func startsEmpty() throws {
        #expect(try emptyStore().people.isEmpty)
    }

    @Test("Adds a person and reads back their city and awake hours")
    func addsAPerson() throws {
        let store = try emptyStore()
        let added = try store.add(name: "Kenji", avatar: .emoji("🎧"), city: city("Tokyo"))

        #expect(store.people.count == 1)
        #expect(store.people.first == added)
        #expect(store.people.first?.place.timeZoneIdentifier == "Asia/Tokyo")
        #expect(store.people.first?.awakeHours == .default)
    }

    @Test("Shows the right local time and status for a newly added person")
    func tokyoReadsCorrectly() throws {
        let store = try emptyStore()
        try store.add(name: "Kenji", avatar: .emoji("🎧"), city: city("Tokyo"),
                      awakeHours: AwakeHours(start: 8, end: 23))

        let person = store.people.first!
        let timeZone = person.place.timeZone!

        // 2026-10-22T04:00:00Z is 13:00 in Tokyo: the middle of the waking day.
        let afternoon = try Date("2026-10-22T04:00:00Z", strategy: .iso8601)
        #expect(LocalTime.hour(at: afternoon, in: timeZone) == 13)
        #expect(CallStatus.status(for: person, at: afternoon) == .good)

        // 2026-10-22T18:00:00Z is 03:00 the next day there.
        let night = try Date("2026-10-22T18:00:00Z", strategy: .iso8601)
        #expect(LocalTime.hour(at: night, in: timeZone) == 3)
        #expect(CallStatus.status(for: person, at: night) == .sleeping)
    }

    @Test("Refuses an eleventh person")
    func enforcesTheLimit() throws {
        let store = try emptyStore()
        let cities = Array(CityCatalog.all.prefix(PeopleStore.Limits.maximumPeople + 1))

        for city in cities.dropLast() {
            try store.add(name: city.name, avatar: .emoji("🙂"), city: city)
        }
        #expect(store.isFull)
        #expect(throws: PeopleStoreError.listIsFull(limit: 10)) {
            try store.add(name: "One too many", avatar: .emoji("🙂"), city: cities.last!)
        }
        #expect(store.people.count == PeopleStore.Limits.maximumPeople)
    }

    @Test("Refuses the same city twice")
    func refusesDuplicates() throws {
        let store = try emptyStore()
        try store.add(name: "Kenji", avatar: .emoji("🎧"), city: city("Tokyo"))

        #expect(throws: PeopleStoreError.alreadyAdded(name: "Tokyo")) {
            try store.add(name: "Someone else", avatar: .emoji("🙂"), city: city("Tokyo"))
        }
    }

    @Test("Refuses an awake window that is not a real day")
    func refusesBadAwakeHours() throws {
        let store = try emptyStore()
        #expect(throws: PeopleStoreError.invalidAwakeHours) {
            try store.add(name: "Backwards", avatar: .emoji("🙂"), city: city("Tokyo"),
                          awakeHours: AwakeHours(start: 22, end: 6))
        }
    }

    @Test("Edits a person in place")
    func editsAPerson() throws {
        let store = try emptyStore()
        let added = try store.add(name: "Kenji", avatar: .emoji("🎧"), city: city("Tokyo"))

        let edited = Person(
            id: added.id,
            name: "Kenji T",
            avatar: .emoji("🌸"),
            place: city("Osaka").place,
            awakeHours: AwakeHours(start: 6, end: 22)
        )
        try store.update(edited)

        #expect(store.people.count == 1)
        #expect(store.people.first == edited)
    }

    @Test("Removes a person")
    func removesAPerson() throws {
        let store = try emptyStore()
        let added = try store.add(name: "Kenji", avatar: .emoji("🎧"), city: city("Tokyo"))
        try store.remove(id: added.id)
        #expect(store.people.isEmpty)
    }

    @Test("Seeds the sample cast only into an empty store")
    func seeding() throws {
        let store = try emptyStore()
        try store.seedWithFixtures()
        let seeded = store.people.count
        #expect(seeded == PeopleStore.Limits.seeded)

        try store.seedWithFixtures()
        #expect(store.people.count == seeded, "seeding twice must not duplicate")
    }

    @Test("Leaves most of the list free after seeding")
    func seedingLeavesRoom() throws {
        let store = try emptyStore()
        try store.seedWithFixtures()
        #expect(store.isFull == false)
        #expect(store.remainingPlaces >= PeopleStore.Limits.maximumPeople / 2,
                "a debug build must not spend most of the limit on samples")
    }

    @Test("Keeps people in the order they were added")
    func keepsOrder() throws {
        let store = try emptyStore()
        for name in ["Tokyo", "Paris", "Lima"] {
            try store.add(name: name, avatar: .emoji("🙂"), city: city(name))
        }
        #expect(store.people.map(\.place.city) == ["Tokyo", "Paris", "Lima"])
    }

    @Test("People survive closing and reopening the store")
    func survivesRelaunch() throws {
        let location = URL.temporaryDirectory.appending(path: "people-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: location) }

        let schema = Schema(versionedSchema: PeopleSchemaV1.self)
        let configuration = ModelConfiguration(url: location)

        let added: Person
        do {
            let container = try ModelContainer(
                for: schema, migrationPlan: PeopleMigrationPlan.self, configurations: configuration
            )
            let store = PeopleStore(container: container)
            added = try store.add(name: "Kenji", avatar: .emoji("🎧"), city: city("Tokyo"),
                                  awakeHours: AwakeHours(start: 6, end: 22))
        }

        // A second container on the same file stands in for the next launch.
        let reopened = try ModelContainer(
            for: schema, migrationPlan: PeopleMigrationPlan.self, configurations: configuration
        )
        let store = PeopleStore(container: reopened)

        #expect(store.people.count == 1)
        #expect(store.people.first == added)
    }
}
