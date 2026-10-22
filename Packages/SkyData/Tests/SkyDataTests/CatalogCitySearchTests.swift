import Foundation
import Testing

@testable import SkyData

@Suite("Catalogue city search")
struct CatalogCitySearchTests {
    @Test("Returns catalogue results through the search seam")
    func findsTokyo() async throws {
        let search: any CitySearching = CatalogCitySearch()
        let results = try await search.cities(matching: "Tokyo")
        #expect(results.first?.name == "Tokyo")
        #expect(results.first?.timeZoneIdentifier == "Asia/Tokyo")
    }

    @Test("Returns nothing for a place that is not there")
    func findsNothing() async throws {
        let results = try await CatalogCitySearch().cities(matching: "Zzzyxborough")
        #expect(results.isEmpty)
    }
}
