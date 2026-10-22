import Testing

@testable import SkyData

@Suite("SkyData module")
struct SkyDataModuleTests {
    @Test("Links against SkyCore")
    func linksAgainstSkyCore() {
        #expect(SkyDataModule.canReachSkyCore())
    }
}
