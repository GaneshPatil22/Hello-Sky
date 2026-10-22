import Foundation
import MapKit

/// Searches Apple's map data, falling back to the bundled catalogue.
///
/// MapKit reaches places the catalogue never will, but it needs the network and
/// does not always return a time zone. Anything it cannot answer falls through
/// to the catalogue, so adding a person never dead-ends.
public struct MapKitCitySearch: CitySearching {
    public init() {}

    public func cities(matching query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = .address

        guard let response = try? await MKLocalSearch(request: request).start() else {
            return CityCatalog.cities(matching: trimmed)
        }
        let found = response.mapItems.compactMap(Self.city(from:))
        return found.isEmpty ? CityCatalog.cities(matching: trimmed) : found
    }

    /// A map result only becomes a city if it knows where it is and what time it is there.
    private static func city(from item: MKMapItem) -> City? {
        guard let timeZone = item.timeZone else { return nil }

        let representations = item.addressRepresentations
        guard let name = item.name ?? representations?.cityWithContext(.short) else { return nil }
        let coordinate = item.location.coordinate

        return City(
            id: "\(Identifier.mapKitPrefix)\(coordinate.latitude),\(coordinate.longitude)",
            name: name,
            country: representations?.regionName ?? "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            timeZoneIdentifier: timeZone.identifier
        )
    }
}

extension MapKitCitySearch {
    enum Identifier {
        /// Marks a city that came from a live search rather than the catalogue.
        static let mapKitPrefix = "mapkit:"
    }
}
