import Foundation

@testable import SkyCore

/// A sunrise and sunset time computed by the `astral` Python library.
///
/// Generated rather than hand-written, so the engine is checked against an
/// independent implementation instead of against itself. Covers the solstices,
/// the equinoxes, a leap day, both European and American daylight-saving
/// weekends, and nine cities including half-hour and 45-minute zones.
struct SolarReference: Decodable {
    let city: String
    let date: String
    let sunrise: Date
    let sunset: Date
    /// Solar noon, the anchor the search runs from: always between the two events.
    let noon: Date
    let latitude: Double
    let longitude: Double

    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }

    /// A short label for test failure messages.
    var label: String { "\(city) \(date)" }
}

extension SolarReference {
    static let all: [SolarReference] = {
        guard let url = Bundle.module.url(forResource: "solar-reference", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("solar-reference.json is missing from the test bundle")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            guard let date = try? Date(text, strategy: .iso8601.time(includingFractionalSeconds: true)) else {
                return try Date(text, strategy: .iso8601)
            }
            return date
        }
        guard let rows = try? decoder.decode([SolarReference].self, from: data) else {
            fatalError("solar-reference.json could not be decoded")
        }
        return rows
    }()

    /// How far from `astral` a computed time may fall.
    ///
    /// The engine uses the low-precision solar model; `astral` uses a fuller
    /// one. Two minutes is the agreement the plan set as acceptable.
    static let tolerance: TimeInterval = 120
}
