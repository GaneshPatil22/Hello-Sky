import Foundation

/// Searches the bundled catalogue. Works offline and gives tests fixed results.
public struct CatalogCitySearch: CitySearching {
    public init() {}

    public func cities(matching query: String) async throws -> [City] {
        CityCatalog.cities(matching: query)
    }
}
