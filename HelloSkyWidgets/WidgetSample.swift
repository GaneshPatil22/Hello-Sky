import SkyCore
import SkyUI

/// Stand-in data for the widget while there is no shared store to read.
///
/// App Groups need the paid Apple Developer Program, so Phase 7 replaces this
/// with the real store. Until then the widget renders a fixed person.
enum WidgetSample {
    static let person = PersonFixtures.kenji
    static let theme = Theme.realistic
    /// Mid-morning, so the scaffold renders a daylight sky rather than black.
    static let sunElevation = 20.0
}
