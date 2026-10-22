import WidgetKit

/// Builds the widget's timeline.
///
/// `TimelineProvider` is closure-based by design; the async form belongs to
/// `AppIntentTimelineProvider`. Phase 7 moves to that, because choosing which
/// person a widget shows needs a configuration intent, and replaces the sample
/// data with the shared App Group store.
struct PersonSkyProvider: TimelineProvider {
    func placeholder(in context: Context) -> PersonSkyEntry {
        PersonSkyEntry(date: .now, person: WidgetSample.person, theme: WidgetSample.theme)
    }

    func getSnapshot(in context: Context, completion: @escaping (PersonSkyEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PersonSkyEntry>) -> Void) {
        let entries = (0..<Schedule.entryCount).compactMap { step in
            Calendar.current
                .date(byAdding: .minute, value: step * Schedule.minutesBetweenEntries, to: .now)
                .map { PersonSkyEntry(date: $0, person: WidgetSample.person, theme: WidgetSample.theme) }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

extension PersonSkyProvider {
    private enum Schedule {
        static let entryCount = 12
        static let minutesBetweenEntries = 15
    }
}
