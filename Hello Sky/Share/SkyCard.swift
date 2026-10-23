import SkyCore
import SkyUI
import SwiftUI

/// Turns a sky into an image worth sending.
@MainActor
enum SkyCard {
    /// Renders the card, or `nil` if the system could not produce an image.
    static func image(
        person: Person,
        weather: SkyWeather,
        date: Date,
        theme: Theme,
        locale: Locale = .current
    ) -> UIImage? {
        let renderer = ImageRenderer(
            content: SkyCardView(person: person, weather: weather, date: date, theme: theme)
                .environment(\.locale, locale)
        )
        // Rendered at device scale so the card is sharp wherever it is posted,
        // not at the size it happens to be laid out on screen.
        renderer.scale = Layout.scale
        return renderer.uiImage
    }

    /// What the share sheet calls it.
    static func title(for person: Person) -> String {
        "\(person.name)'s sky"
    }

    private enum Layout {
        static let scale: CGFloat = 3
    }
}
