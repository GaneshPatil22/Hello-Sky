import Testing

@testable import SkyUI

@Suite("SkyUI module")
struct SkyUIModuleTests {
    @Test("Links against SkyCore and SwiftUI")
    func linksAgainstDependencies() {
        #expect(SkyUIModule.canReachDependencies())
    }
}
