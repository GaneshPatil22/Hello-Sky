import Foundation

/// How many calls a day the app allows itself.
///
/// WeatherKit includes 500,000 calls a month across all users, so an individual
/// device staying modest is what keeps the app free as it grows. The counter
/// resets each UTC day.
public actor WeatherBudget {
    public let dailyLimit: Int

    private var day: Date
    private var used: Int

    public init(dailyLimit: Int = Defaults.dailyLimit, now: Date = .now) {
        self.dailyLimit = dailyLimit
        self.day = Self.startOfDay(for: now)
        self.used = 0
    }

    /// Whether another call is allowed, counting it if so.
    public func claimCall(at date: Date = .now) -> Bool {
        rollOverIfNeeded(at: date)
        guard used < dailyLimit else { return false }
        used += 1
        return true
    }

    public func callsUsed(at date: Date = .now) -> Int {
        rollOverIfNeeded(at: date)
        return used
    }

    private func rollOverIfNeeded(at date: Date) {
        let today = Self.startOfDay(for: date)
        guard today != day else { return }
        day = today
        used = 0
    }

    private static func startOfDay(for date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar.startOfDay(for: date)
    }
}

extension WeatherBudget {
    public enum Defaults {
        /// Ten places refreshed hourly through a waking day, with room to spare.
        public static let dailyLimit = 200
    }
}
