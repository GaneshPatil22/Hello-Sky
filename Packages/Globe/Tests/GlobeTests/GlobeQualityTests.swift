import Foundation
import Testing

@testable import Globe

@Suite("Globe quality")
struct GlobeQualityTests {
    @Test("Tiers are ordered and drop work as they go down")
    func tiersAreOrdered() {
        #expect(GlobeQuality.low < .medium)
        #expect(GlobeQuality.medium < .high)
        #expect(GlobeQuality.high.textureWidth > GlobeQuality.low.textureWidth)
        #expect(GlobeQuality.high.drawsAtmosphere)
        #expect(!GlobeQuality.low.drawsClouds)
    }

    @Test("Texture memory stays within what a phone can hold")
    func textureMemoryIsReasonable() {
        // Four textures at the top tier — day, night, cloud, specular.
        let highTotal = GlobeQuality.high.textureBytes * 4
        #expect(highTotal < 200 * 1_024 * 1_024, "high tier wants \(highTotal / 1_024 / 1_024)MB")

        let lowTotal = GlobeQuality.low.textureBytes * 4
        #expect(lowTotal < 20 * 1_024 * 1_024, "low tier wants \(lowTotal / 1_024 / 1_024)MB")
    }

    @Test("Sustained slow frames drop the tier")
    func dropsWhenSlow() {
        var governor = GlobeQualityGovernor(quality: .high)
        for _ in 0..<GlobeQualityGovernor.Thresholds.slowFramesBeforeDropping {
            governor.record(frameDuration: 1.0 / 30)
        }
        #expect(governor.quality == .medium)
    }

    @Test("One slow frame is not enough to drop")
    func ignoresASingleHitch() {
        var governor = GlobeQualityGovernor(quality: .high)
        governor.record(frameDuration: 1.0 / 20)
        #expect(governor.quality == .high)
    }

    @Test("It takes far more evidence to go back up than to come down")
    func recoveryIsSlower() {
        var governor = GlobeQualityGovernor(quality: .high)
        for _ in 0..<GlobeQualityGovernor.Thresholds.slowFramesBeforeDropping {
            governor.record(frameDuration: 1.0 / 30)
        }
        #expect(governor.quality == .medium)

        // Exactly as many fast frames as it took to drop: not enough.
        for _ in 0..<GlobeQualityGovernor.Thresholds.slowFramesBeforeDropping {
            governor.record(frameDuration: 1.0 / 120)
        }
        #expect(governor.quality == .medium)

        for _ in 0..<GlobeQualityGovernor.Thresholds.fastFramesBeforeRaising {
            governor.record(frameDuration: 1.0 / 120)
        }
        #expect(governor.quality == .high)
    }

    @Test("It never drops below the lowest tier")
    func stopsAtTheFloor() {
        var governor = GlobeQualityGovernor(quality: .low)
        for _ in 0..<1_000 {
            governor.record(frameDuration: 1.0 / 10)
        }
        #expect(governor.quality == .low)
    }

    @Test("A locked tier stays put, which is how an older phone gets stood in for")
    func lockedTierIsHeld() {
        var governor = GlobeQualityGovernor(quality: .low, isLocked: true)
        for _ in 0..<1_000 {
            governor.record(frameDuration: 1.0 / 120)
        }
        #expect(governor.quality == .low)
    }
}
