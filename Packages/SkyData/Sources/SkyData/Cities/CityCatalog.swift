import Foundation

/// The bundled list of cities.
///
/// Carried in the app so adding a person works with no network, and so tests
/// and previews never depend on a live search. `Tools/generate-city-catalog.py`
/// regenerates it; time zone identifiers are validated there.
public enum CityCatalog {
    public static let all: [City] = {
        guard let url = Bundle.module.url(forResource: Resource.name, withExtension: Resource.extension),
              let data = try? Data(contentsOf: url),
              let cities = try? JSONDecoder().decode([City].self, from: data) else {
            assertionFailure("\(Resource.name).\(Resource.extension) is missing or malformed")
            return []
        }
        return cities
    }()

    /// Cities whose name or country matches `query`, best matches first.
    ///
    /// Uses `localizedStandardContains`, so accents and case behave the way a
    /// person typing in their own language expects.
    public static func cities(matching query: String) -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let prefixMatches = all.filter { $0.name.localizedStandardHasPrefix(trimmed) }
        let otherMatches = all.filter {
            !$0.name.localizedStandardHasPrefix(trimmed)
                && ($0.name.localizedStandardContains(trimmed) || $0.country.localizedStandardContains(trimmed))
        }
        return Array((prefixMatches + otherMatches).prefix(Limits.results))
    }

    public static func city(id: String) -> City? {
        all.first { $0.id == id }
    }
}

extension CityCatalog {
    enum Resource {
        static let name = "cities"
        static let `extension` = "json"
    }

    public enum Limits {
        /// More than this is a list nobody scrolls.
        public static let results = 25
    }
}

extension String {
    /// `localizedStandardContains`, anchored to the start.
    func localizedStandardHasPrefix(_ prefix: String) -> Bool {
        range(of: prefix, options: [.caseInsensitive, .diacriticInsensitive, .anchored], locale: .current) != nil
    }
}
