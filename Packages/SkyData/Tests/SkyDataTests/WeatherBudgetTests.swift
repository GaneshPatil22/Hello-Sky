import Foundation
import Testing

@testable import SkyData

@Suite("Weather budget")
struct WeatherBudgetTests {
    private let day = try! Date("2026-10-22T10:00:00Z", strategy: .iso8601)

    @Test("Allows calls up to the limit and no further")
    func enforcesTheLimit() async {
        let budget = WeatherBudget(dailyLimit: 3, now: day)

        for _ in 0..<3 {
            #expect(await budget.claimCall(at: day))
        }
        #expect(await budget.claimCall(at: day) == false)
        #expect(await budget.callsUsed(at: day) == 3)
    }

    @Test("Starts again the next day")
    func resetsDaily() async {
        let budget = WeatherBudget(dailyLimit: 1, now: day)
        #expect(await budget.claimCall(at: day))
        #expect(await budget.claimCall(at: day) == false)

        let tomorrow = day.addingTimeInterval(24 * 3_600)
        #expect(await budget.claimCall(at: tomorrow))
        #expect(await budget.callsUsed(at: tomorrow) == 1)
    }

    @Test("Counts a day in UTC, not in whatever zone the phone is in")
    func dayBoundaryIsUTC() async {
        let budget = WeatherBudget(dailyLimit: 1, now: day)
        #expect(await budget.claimCall(at: day))

        let lateSameUTCDay = try! Date("2026-10-22T23:30:00Z", strategy: .iso8601)
        #expect(await budget.claimCall(at: lateSameUTCDay) == false, "still the same UTC day")

        let justAfterMidnight = try! Date("2026-10-23T00:30:00Z", strategy: .iso8601)
        #expect(await budget.claimCall(at: justAfterMidnight))
    }
}
