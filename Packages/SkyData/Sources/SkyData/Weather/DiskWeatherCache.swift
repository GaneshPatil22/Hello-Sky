import Foundation
import SkyCore

/// Readings kept as small files in the caches directory.
///
/// The caches directory is the right home: the system may clear it under disk
/// pressure, and losing a weather reading costs one request, not data.
public actor DiskWeatherCache: WeatherCaching {
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directory: URL? = nil) {
        self.directory = directory ?? URL.cachesDirectory.appending(path: Constants.folderName)
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    public func reading(for key: WeatherCacheKey) async -> SkyWeather? {
        guard let data = try? Data(contentsOf: url(for: key)) else { return nil }
        return try? decoder.decode(SkyWeather.self, from: data)
    }

    public func store(_ weather: SkyWeather, for key: WeatherCacheKey) async {
        guard let data = try? encoder.encode(weather) else { return }
        try? data.write(to: url(for: key), options: .atomic)
    }

    public func removeAll() async {
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func url(for key: WeatherCacheKey) -> URL {
        directory.appending(path: key.fileName)
    }
}

extension DiskWeatherCache {
    enum Constants {
        static let folderName = "SkyWeather"
    }
}
