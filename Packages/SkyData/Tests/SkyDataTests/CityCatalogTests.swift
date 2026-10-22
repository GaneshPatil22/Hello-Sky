import Foundation
import Testing

@testable import SkyData

@Suite("City catalogue")
struct CityCatalogTests {
    @Test("Loads the bundled cities")
    func loads() {
        #expect(CityCatalog.all.count > 150, "only \(CityCatalog.all.count) cities loaded")
    }

    @Test("Every city names a time zone the system knows")
    func timeZonesResolve() {
        for city in CityCatalog.all {
            #expect(TimeZone(identifier: city.timeZoneIdentifier) != nil,
                    "\(city.name) names \(city.timeZoneIdentifier)")
        }
    }

    @Test("Every city has a coordinate in range and a unique id")
    func coordinatesAndIdentifiers() {
        var seen = Set<String>()
        for city in CityCatalog.all {
            #expect(city.coordinate.isValid, "\(city.name) is out of range")
            #expect(seen.insert(city.id).inserted, "\(city.id) appears twice")
            #expect(!city.name.isEmpty)
        }
    }

    @Test("Covers half-hour and 45-minute offsets")
    func coversAwkwardOffsets() {
        let identifiers = Set(CityCatalog.all.map(\.timeZoneIdentifier))
        #expect(identifiers.contains("Asia/Kolkata"), "no half-hour zone")
        #expect(identifiers.contains("Asia/Kathmandu"), "no 45-minute zone")
        #expect(identifiers.contains("America/St_Johns"), "no Newfoundland")
    }

    @Test("Spans both hemispheres and the whole longitude range")
    func spansTheGlobe() {
        let latitudes = CityCatalog.all.map(\.latitude)
        let longitudes = CityCatalog.all.map(\.longitude)
        #expect(latitudes.min()! < -30)
        #expect(latitudes.max()! > 60)
        #expect(longitudes.min()! < -120)
        #expect(longitudes.max()! > 150)
    }

    @Test("Finds a city by name, putting prefix matches first")
    func searchPrefersPrefixes() {
        let results = CityCatalog.cities(matching: "San")
        #expect(results.contains { $0.name == "San Francisco" })
        #expect(results.first?.name.hasPrefix("San") == true, "got \(results.first?.name ?? "nothing")")
    }

    @Test("Finds cities by country too")
    func searchesCountries() {
        let results = CityCatalog.cities(matching: "Japan")
        #expect(results.contains { $0.name == "Tokyo" })
    }

    @Test("Ignores case and surrounding spaces")
    func searchIsForgiving() {
        #expect(CityCatalog.cities(matching: "  tOkYo ").first?.name == "Tokyo")
    }

    @Test("An empty query returns nothing rather than everything")
    func emptyQuery() {
        #expect(CityCatalog.cities(matching: "").isEmpty)
        #expect(CityCatalog.cities(matching: "   ").isEmpty)
    }

    @Test("Caps how many results come back")
    func capsResults() {
        #expect(CityCatalog.cities(matching: "a").count <= CityCatalog.Limits.results)
    }

    @Test("Looks a city up by id")
    func lookupByIdentifier() {
        let tokyo = CityCatalog.cities(matching: "Tokyo").first!
        #expect(CityCatalog.city(id: tokyo.id) == tokyo)
        #expect(CityCatalog.city(id: "nowhere") == nil)
    }
}
