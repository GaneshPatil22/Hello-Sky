import Foundation
import SkyCore
import SwiftData
import Testing

@testable import SkyData

/// A future shape of the store, defined here rather than shipped.
///
/// It adds one optional property to the same entity, which is the shape every
/// planned change has — v2's photo avatars add a value, they do not remove one.
/// Proving it migrates now means the first real change is routine.
enum PeopleSchemaV2Preview: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [StoredPerson.self] }

    @Model
    final class StoredPerson {
        var id: String = ""
        var name: String = ""
        var avatarKind: String = StoredAvatarKind.emoji.rawValue
        var avatarValue: String = ""
        var cityID: String = ""
        var cityName: String = ""
        var latitude: Double = 0
        var longitude: Double = 0
        var timeZoneIdentifier: String = ""
        var awakeStart: Double = 8
        var awakeEnd: Double = 23
        var sortOrder: Int = 0
        /// The new property. Optional, so existing rows need no value.
        var note: String?

        init() {}
    }
}

enum PreviewMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [PeopleSchemaV1.self, PeopleSchemaV2Preview.self] }
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: PeopleSchemaV1.self, toVersion: PeopleSchemaV2Preview.self)]
    }
}

@MainActor
@Suite("People store migration")
struct PeopleMigrationTests {
    @Test("People written under v1 survive opening under a later schema")
    func survivesASchemaChange() throws {
        let location = URL.temporaryDirectory.appending(path: "migration-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: location) }

        let added: Person
        do {
            let container = try ModelContainer(
                for: Schema(versionedSchema: PeopleSchemaV1.self),
                migrationPlan: PeopleMigrationPlan.self,
                configurations: ModelConfiguration(url: location)
            )
            let store = PeopleStore(container: container)
            let tokyo = CityCatalog.cities(matching: "Tokyo").first { $0.name == "Tokyo" }!
            added = try store.add(name: "Kenji", avatar: .emoji("🎧"), city: tokyo,
                                  awakeHours: AwakeHours(start: 6, end: 22))
        }

        let upgraded = try ModelContainer(
            for: Schema(versionedSchema: PeopleSchemaV2Preview.self),
            migrationPlan: PreviewMigrationPlan.self,
            configurations: ModelConfiguration(url: location)
        )
        let rows = try ModelContext(upgraded).fetch(FetchDescriptor<PeopleSchemaV2Preview.StoredPerson>())

        #expect(rows.count == 1)
        #expect(rows.first?.id == added.id)
        #expect(rows.first?.name == "Kenji")
        #expect(rows.first?.cityName == "Tokyo")
        #expect(rows.first?.awakeStart == 6)
        #expect(rows.first?.note == nil, "a new optional starts empty on an old row")
    }
}
