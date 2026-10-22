import Foundation

/// Where city search results come from.
///
/// The seam exists so the bundled catalogue can stand in for MapKit in tests,
/// previews, and offline use, and so no screen knows which one it is talking to.
public protocol CitySearching: Sendable {
    func cities(matching query: String) async throws -> [City]
}
