import Testing

@testable import SkyUI

@Suite("Seeded generator")
struct SeededGeneratorTests {
    @Test("The same seed gives the same sequence")
    func isRepeatable() {
        var first = SeededGenerator(seed: 42)
        var second = SeededGenerator(seed: 42)
        let a = (0..<20).map { _ in first.next() }
        let b = (0..<20).map { _ in second.next() }
        #expect(a == b)
    }

    @Test("Different seeds give different sequences")
    func seedsSeparate() {
        var first = SeededGenerator(seed: 1)
        var second = SeededGenerator(seed: 2)
        #expect(first.next() != second.next())
    }

    @Test("A zero seed still produces a varied sequence")
    func zeroSeedIsHandled() {
        var generator = SeededGenerator(seed: 0)
        let values = (0..<10).map { _ in generator.next() }
        #expect(Set(values).count == values.count)
    }

    @Test("Fractions stay inside zero and one")
    func fractionsAreInRange() {
        var generator = SeededGenerator(seed: 7)
        for _ in 0..<1_000 {
            let value = generator.nextFraction()
            #expect(value >= 0 && value < 1)
        }
    }

    @Test("Ranged values stay inside their range")
    func rangedValuesAreInRange() {
        var generator = SeededGenerator(seed: 11)
        for _ in 0..<1_000 {
            let value = generator.next(in: -5...5)
            #expect(value >= -5 && value <= 5)
        }
    }
}
