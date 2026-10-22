import SwiftUI
import WidgetKit

/// A person's local time over their sky.
///
/// Phase 7 adds the medium and Lock Screen families and draws the real sky
/// behind the time.
struct PersonSkyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Kind.personSky, provider: PersonSkyProvider()) { entry in
            PersonSkyWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.theme.sky
                        .gradient(forSunElevation: WidgetSample.sunElevation)
                        .linearGradient
                }
        }
        .configurationDisplayName("Someone's sky")
        .description("A person's local time over the sky where they are.")
        .supportedFamilies([.systemSmall])
    }
}

extension PersonSkyWidget {
    enum Kind {
        static let personSky = "PersonSky"
    }
}

#Preview(as: .systemSmall) {
    PersonSkyWidget()
} timeline: {
    PersonSkyEntry(date: .now, person: WidgetSample.person, theme: WidgetSample.theme)
}
