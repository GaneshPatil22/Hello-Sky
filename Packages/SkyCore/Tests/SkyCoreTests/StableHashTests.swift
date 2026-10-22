import Testing

@testable import SkyCore

@Suite("Stable hash")
struct StableHashTests {
    @Test("Gives the same answer for the same text every time")
    func isDeterministic() {
        // Hard-coded because the point is that it never changes, in this run or
        // any other. A different answer here means seeded art has shifted.
        #expect("tokyo".stableHash == 2774413621751051833)
        #expect("".stableHash == 14_695_981_039_346_656_037)
    }

    @Test("Different places get different seeds")
    func separatesPlaces() {
        let hashes = PersonFixtures.all.map(\.place.id.stableHash)
        #expect(Set(hashes).count == hashes.count)
    }
}
