import Foundation

/// What a cached reading is filed under: a place and an hour.
///
/// Weather is asked for far more often than it changes, and every screen
/// showing the same city in the same hour wants the same answer.
public struct WeatherCacheKey: Hashable, Sendable, Codable {
    public let placeID: String
    /// The start of the hour containing the moment asked about.
    public let hour: Date

    public init(placeID: String, date: Date) {
        self.placeID = placeID
        let seconds = date.timeIntervalSince1970
        self.hour = Date(timeIntervalSince1970: seconds - seconds.truncatingRemainder(dividingBy: Constants.hour))
    }
}

extension WeatherCacheKey {
    enum Constants {
        static let hour: TimeInterval = 3_600
    }

    /// A file-system-safe name for this key.
    var fileName: String {
        let safePlace = placeID.replacing(/[^A-Za-z0-9_-]/, with: "_")
        return "\(safePlace)-\(Int(hour.timeIntervalSince1970)).json"
    }
}
