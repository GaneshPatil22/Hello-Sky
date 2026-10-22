import Foundation
import Testing

@testable import SkyUI

@Suite("Sky transition")
struct SkyTransitionTests {
    @Test("Starts on the globe with nobody showing")
    func startsOnTheGlobe() {
        let transition = SkyTransition()
        #expect(transition.phase == .globe)
        #expect(transition.personID == nil)
        #expect(!transition.isShowingSky)
        #expect(!transition.isMoving)
    }

    @Test("Runs the whole way there and back")
    func fullRoundTrip() {
        var transition = SkyTransition()

        let opened = transition.open(personID: "kenji")
        #expect(opened)
        #expect(transition.phase == .opening(personID: "kenji"))
        #expect(transition.isMoving)

        transition.finishOpening()
        #expect(transition.phase == .sky(personID: "kenji"))
        #expect(!transition.isMoving)
        #expect(transition.isShowingSky)

        let closed = transition.close()
        #expect(closed)
        #expect(transition.phase == .closing(personID: "kenji"))
        #expect(transition.isMoving)

        transition.finishClosing()
        #expect(transition.phase == .globe)
        #expect(transition.personID == nil)
    }

    @Test("Refuses to open a second sky while one is opening")
    func cannotOpenTwice() {
        var transition = SkyTransition()
        let opened = transition.open(personID: "kenji")
        let second = transition.open(personID: "ava")
        #expect(opened)
        #expect(!second, "a second tap must not take over")
        #expect(transition.personID == "kenji")
    }

    @Test("Refuses to open while closing")
    func cannotOpenWhileClosing() {
        var transition = SkyTransition()
        transition.open(personID: "kenji")
        transition.finishOpening()
        transition.close()

        let opened = transition.open(personID: "ava")
        #expect(!opened)
        #expect(transition.personID == "kenji")
    }

    @Test("Refuses to close when there is nothing open")
    func cannotCloseTheGlobe() {
        var transition = SkyTransition()
        let closed = transition.close()
        #expect(!closed)
        #expect(transition.phase == .globe)
    }

    @Test("Finishing a step that is not running changes nothing")
    func strayFinishesAreIgnored() {
        var transition = SkyTransition()
        transition.finishOpening()
        #expect(transition.phase == .globe)

        transition.finishClosing()
        #expect(transition.phase == .globe)

        transition.open(personID: "kenji")
        transition.finishClosing()
        #expect(transition.phase == .opening(personID: "kenji"), "closing must not skip the opening")
    }

    @Test("Opening the same person again while their sky is up is refused")
    func cannotReopenTheSameSky() {
        var transition = SkyTransition()
        transition.open(personID: "kenji")
        transition.finishOpening()
        let reopened = transition.open(personID: "kenji")
        #expect(!reopened)
    }

    @Test("The whole move is about a second and a half")
    func timingMatchesThePlan() {
        #expect(SkyTransition.Timing.total > 1.0)
        #expect(SkyTransition.Timing.total < 1.6)
        #expect(SkyTransition.Timing.close < SkyTransition.Timing.focus, "coming back should be quicker")
    }
}
