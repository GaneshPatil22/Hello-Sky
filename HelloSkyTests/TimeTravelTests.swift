import Foundation
import Testing

@testable import Hello_Sky

@MainActor
@Suite("Time travel")
struct TimeTravelTests {
    @Test("Starts at now")
    func startsAtNow() {
        let time = TimeTravel()
        #expect(time.isNow)
        #expect(time.offsetHours == 0)
    }

    @Test("The offset moves the moment every screen draws")
    func offsetMovesTheDate() {
        let time = TimeTravel()
        let base = Date(timeIntervalSince1970: 1_792_000_000)

        time.scrubbedOffset = 3
        #expect(time.date(from: base).timeIntervalSince(base) == 3 * 3_600)

        time.scrubbedOffset = -2.5
        #expect(time.date(from: base).timeIntervalSince(base) == -2.5 * 3_600)
        #expect(!time.isNow)
    }

    @Test("Jumping back to now lands exactly there")
    func jumpToNow() {
        let time = TimeTravel()
        time.scrubbedOffset = 7
        time.jumpToNow()
        #expect(time.isNow)
    }

    @Test("Winding back travels rather than arriving at once")
    func windBackTravels() async {
        let time = TimeTravel()
        time.scrubbedOffset = 10
        time.returnToNow()

        // Part way through it should be somewhere between where it started and
        // now, which is the whole point of the wind-back.
        try? await Task.sleep(for: .milliseconds(250))
        let midway = time.offsetHours
        #expect(midway < 10, "did not set off")
        #expect(midway > 0, "arrived immediately, which is the bug this prevents")

        try? await Task.sleep(for: .milliseconds(900))
        #expect(time.isNow, "did not finish, left at \(time.offsetHours)")
    }

    @Test("Touching the slider takes over from a wind-back in progress")
    func scrubbingCancelsTheWindBack() async {
        let time = TimeTravel()
        time.scrubbedOffset = 10
        time.returnToNow()

        try? await Task.sleep(for: .milliseconds(120))
        time.scrubbedOffset = -4

        try? await Task.sleep(for: .milliseconds(400))
        #expect(time.offsetHours == -4, "the wind-back kept writing, landing at \(time.offsetHours)")
    }

    @Test("Winding back from now does nothing at all")
    func windBackFromNowIsANoop() async {
        let time = TimeTravel()
        time.returnToNow()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(time.isNow)
    }

    @Test("The curve leaves and arrives gently")
    func easingIsSmooth() {
        #expect(TimeTravel.eased(0) == 0)
        #expect(TimeTravel.eased(1) == 1)
        #expect(abs(TimeTravel.eased(0.5) - 0.5) < 0.001)
        // Slower than linear at the start, faster in the middle.
        #expect(TimeTravel.eased(0.1) < 0.1)
        #expect(TimeTravel.eased(0.9) > 0.9)
        #expect(TimeTravel.eased(-1) == 0)
        #expect(TimeTravel.eased(2) == 1)
    }
}
