import Testing

@testable import SkyCore

@Suite("Coordinate")
struct CoordinateTests {
    @Test("Accepts a point inside both ranges")
    func acceptsPointInRange() {
        let delhi = Coordinate(latitude: 28.6139, longitude: 77.2090)
        #expect(delhi.isValid)
    }

    @Test("Accepts the exact bounds of both ranges")
    func acceptsBounds() {
        #expect(Coordinate(latitude: 90, longitude: 180).isValid)
        #expect(Coordinate(latitude: -90, longitude: -180).isValid)
    }

    @Test("Rejects a point outside either range")
    func rejectsPointOutOfRange() {
        #expect(!Coordinate(latitude: 91, longitude: 0).isValid)
        #expect(!Coordinate(latitude: 0, longitude: 181).isValid)
    }
}
