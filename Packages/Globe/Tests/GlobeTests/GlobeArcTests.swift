import Foundation
import SkyCore
import Testing
import simd

@testable import Globe

@Suite("Globe arc")
struct GlobeArcTests {
    private let london = PersonFixtures.you.place.coordinate
    private let tokyo = PersonFixtures.kenji.place.coordinate
    private let newYork = PersonFixtures.ava.place.coordinate

    @Test("Starts and ends on the ground")
    func endsTouchTheSurface() {
        let arc = GlobeArc(from: london, to: tokyo)
        #expect(abs(Double(simd_length(arc.points.first!)) - 1) < 0.001)
        #expect(abs(Double(simd_length(arc.points.last!)) - 1) < 0.001)
    }

    @Test("Rises in the middle, like a flight path")
    func risesInTheMiddle() {
        let arc = GlobeArc(from: london, to: tokyo)
        let middle = Double(simd_length(arc.points[arc.points.count / 2]))
        #expect(middle > 1.02, "midpoint barely left the ground at \(middle)")
        #expect(middle < 1 + GlobeArc.Layout.maximumRise + 0.001)
    }

    @Test("Stays close enough to the globe to read as a path, not an orbit")
    func staysNearTheGlobe() {
        for person in PersonFixtures.all {
            let arc = GlobeArc(from: london, to: person.place.coordinate)
            let highest = Double(arc.points.map { simd_length($0) }.max() ?? 1)
            #expect(highest < 1.15, "\(person.place.city) rose to \(highest)")
        }
    }

    @Test("A longer journey rises higher than a short one")
    func distanceDrivesTheRise() {
        let short = GlobeArc(from: london, to: newYork)
        let long = GlobeArc(from: london, to: tokyo)
        let shortPeak = Double(short.points.map { simd_length($0) }.max() ?? 1)
        let longPeak = Double(long.points.map { simd_length($0) }.max() ?? 1)
        #expect(longPeak > shortPeak)
    }

    @Test("Follows the great circle rather than cutting through the Earth")
    func followsTheSurface() {
        let arc = GlobeArc(from: london, to: tokyo)
        // Every point should be outside the sphere, never inside it.
        for point in arc.points {
            #expect(Double(simd_length(point)) >= 0.999)
        }
    }

    @Test("Length grows with separation, which is what paces the travelling dot")
    func lengthTracksSeparation() {
        #expect(GlobeArc(from: london, to: tokyo).length
            > GlobeArc(from: london, to: newYork).length)
    }

    @Test("A person at their own location produces no arc to travel")
    func noArcToYourself() {
        let arc = GlobeArc(from: london, to: london)
        #expect(arc.length == 0)
    }
}
