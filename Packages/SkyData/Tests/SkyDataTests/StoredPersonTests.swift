import Foundation
import SkyCore
import Testing

@testable import SkyData

@Suite("Stored person mapping")
struct StoredPersonTests {
    @Test("Survives a round trip unchanged")
    func roundTrip() {
        for original in PersonFixtures.all {
            let stored = StoredPerson(person: original, sortOrder: 0)
            #expect(stored.person == original, "\(original.name) changed in the store")
        }
    }

    @Test("Skips a row whose avatar kind this version does not understand")
    func unknownAvatarKind() {
        let stored = StoredPerson(person: PersonFixtures.you, sortOrder: 0)
        stored.avatarKind = "photo" // what v2 will write
        #expect(stored.person == nil)
    }

    @Test("Skips a row naming a time zone the system does not have")
    func unknownTimeZone() {
        let stored = StoredPerson(person: PersonFixtures.you, sortOrder: 0)
        stored.timeZoneIdentifier = "Mars/Olympus"
        #expect(stored.person == nil)
    }

    @Test("Updating keeps the person's place in the list")
    func updateKeepsSortOrder() {
        let stored = StoredPerson(person: PersonFixtures.you, sortOrder: 7)
        stored.update(from: PersonFixtures.kenji)

        #expect(stored.sortOrder == 7)
        #expect(stored.name == PersonFixtures.kenji.name)
        #expect(stored.cityName == "Tokyo")
    }
}
