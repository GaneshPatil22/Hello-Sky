import SkyCore
import SwiftUI

/// Phase 0 scaffolding.
///
/// Phase 0 continues with `Theme` and `ThemeRegistry`; Phase 4 adds `SkyView`
/// and the renderer. This file exists only so the module compiles and its
/// dependencies are proven by a test from the first commit.
public enum SkyUIModule {
    static let referencePoint = Coordinate(latitude: 0, longitude: 0)

    /// Confirms this module links against `SkyCore` and SwiftUI. Removed once `Theme` lands.
    public static func canReachDependencies() -> Bool {
        referencePoint.isValid && Color.clear != Color.black
    }
}
