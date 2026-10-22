import Foundation
import Testing

@testable import SkyCore

@Suite("Overlap")
struct OverlapTests {
    private let startOfSearch = Date(timeIntervalSince1970: 1_792_000_000)

    @Test("Samples exactly twenty-four hours")
    func coversOneDay() {
        let slots = Overlap.awakeSlots(for: PersonFixtures.you, from: startOfSearch)
        #expect(slots.count == Overlap.Resolution.slotCount)
        #expect(Double(slots.count) * Overlap.Resolution.slot == 24 * 3_600)
    }

    @Test("A person overlaps themselves for their whole waking day")
    func selfOverlapIsTheWakingWindow() {
        let you = PersonFixtures.you
        guard let window = Overlap.bestWindow(between: you, and: you, from: startOfSearch) else {
            Issue.record("a person must overlap themselves")
            return
        }
        #expect(window.hours > 0)
        #expect(window.hours <= you.awakeHours.duration + 0.5)
    }

    @Test("Finds a workable window between London and New York")
    func londonAndNewYork() {
        guard let window = Overlap.bestWindow(
            between: PersonFixtures.you,
            and: PersonFixtures.ava,
            from: startOfSearch
        ) else {
            Issue.record("London and New York share waking hours")
            return
        }
        // Five hours apart with similar routines leaves most of an afternoon.
        #expect(window.hours > 5, "only found \(window.hours) hours")
        #expect(window.start < window.end)
    }

    @Test("Returns nothing when two people are opposite each other")
    func noOverlapAcrossTheWorld() {
        let nightOwl = Person(
            id: "owl",
            name: "Owl",
            avatar: .emoji("🦉"),
            place: PersonFixtures.you.place,
            awakeHours: AwakeHours(start: 9, end: 11)
        )
        let opposite = Person(
            id: "opposite",
            name: "Opposite",
            avatar: .emoji("🌏"),
            place: PersonFixtures.dad.place,
            awakeHours: AwakeHours(start: 9, end: 11)
        )
        #expect(Overlap.bestWindow(between: nightOwl, and: opposite, from: startOfSearch) == nil)
    }

    @Test("The window lies inside both people's waking hours")
    func windowRespectsBothSchedules() {
        for other in PersonFixtures.all where other.id != PersonFixtures.you.id {
            guard let window = Overlap.bestWindow(
                between: PersonFixtures.you,
                and: other,
                from: startOfSearch
            ) else { continue }

            let midpoint = window.start.addingTimeInterval(window.duration / 2)
            for person in [PersonFixtures.you, other] {
                guard let timeZone = person.place.timeZone else { continue }
                let hour = LocalTime.hour(at: midpoint, in: timeZone)
                #expect(person.awakeHours.contains(localHour: hour),
                        "\(person.name) is asleep at \(hour) during the window with \(other.name)")
            }
        }
    }

    @Test("Overlap is the same whichever person is asked first")
    func orderDoesNotMatter() {
        for other in PersonFixtures.all {
            let forwards = Overlap.bestWindow(between: PersonFixtures.you, and: other, from: startOfSearch)
            let backwards = Overlap.bestWindow(between: other, and: PersonFixtures.you, from: startOfSearch)
            #expect(forwards == backwards, "\(other.name) gave different answers")
        }
    }
}
