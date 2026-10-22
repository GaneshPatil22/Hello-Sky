import Foundation
import Testing

@testable import SkyUI

@Suite("Circular reveal")
struct CircularRevealTests {
    private let size = CGSize(width: 400, height: 800)

    @Test("The circle reaches the furthest corner from wherever it starts")
    func coversEveryCorner() {
        let origins = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: size.width, y: size.height),
            CGPoint(x: size.width / 2, y: size.height / 2),
            CGPoint(x: 10, y: size.height - 10),
        ]
        for origin in origins {
            let radius = CircularReveal.coveringDiameter(from: origin, in: size) / 2
            for corner in [CGPoint(x: 0, y: 0), CGPoint(x: size.width, y: 0),
                           CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height)] {
                let distance = hypot(corner.x - origin.x, corner.y - origin.y)
                #expect(radius >= distance - 0.001, "origin \(origin) misses corner \(corner)")
            }
        }
    }

    @Test("A circle from the middle is smaller than one from a corner")
    func middleIsCheapest() {
        let middle = CircularReveal.coveringDiameter(
            from: CGPoint(x: size.width / 2, y: size.height / 2), in: size)
        let corner = CircularReveal.coveringDiameter(from: .zero, in: size)
        #expect(middle < corner)
    }

    @Test("Progress drives the animation")
    func progressIsAnimatable() {
        var reveal = CircularReveal(progress: 0, origin: .zero)
        reveal.animatableData = 0.5
        #expect(reveal.progress == 0.5)
    }
}
