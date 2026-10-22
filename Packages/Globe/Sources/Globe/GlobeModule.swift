import SkyCore
import SkyUI

/// Phase 0 scaffolding.
///
/// Phase 5 fills this module with the RealityKit scene, the day/night shader,
/// and the people markers, and opens with a spike proving custom materials work
/// on iOS. This file exists only so the module compiles and its dependencies are
/// proven by a test from the first commit.
public enum GlobeModule {
    static let referencePoint = Coordinate(latitude: 0, longitude: 0)

    /// Confirms this module links against `SkyCore` and `SkyUI`. Removed in Phase 5.
    public static func canReachDependencies() -> Bool {
        referencePoint.isValid && SkyUIModule.canReachDependencies()
    }
}
