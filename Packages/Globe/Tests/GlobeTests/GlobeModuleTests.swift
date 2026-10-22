import Testing

@testable import Globe

@Suite("Globe module")
struct GlobeModuleTests {
    @Test("Links against SkyCore and SkyUI")
    func linksAgainstDependencies() {
        #expect(GlobeModule.canReachDependencies())
    }
}
