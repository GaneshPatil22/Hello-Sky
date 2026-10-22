import SkyCore
import SkyUI
import WidgetKit

/// One moment on a widget's timeline: who, when, and in which look.
struct PersonSkyEntry: TimelineEntry {
    let date: Date
    let person: Person
    let theme: Theme
}
