import CoreTransferable
import SkyCore
import SkyUI
import SwiftUI
import UniformTypeIdentifiers

/// A sky card, rendered only if someone actually shares it.
///
/// `ShareLink` evaluates a plain image the moment the view is built, which on
/// a screen that redraws every frame would mean rendering a card every frame.
/// Going through `Transferable` defers the work to the share itself.
struct SkyCardTransfer: Transferable {
    let person: Person
    let weather: SkyWeather
    let date: Date
    let theme: Theme
    let locale: Locale

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { card in
            try await card.pngData()
        }
        .suggestedFileName { card in
            "\(card.person.name)-sky.png"
        }
    }

    @MainActor
    private func render() -> UIImage? {
        SkyCard.image(person: person, weather: weather, date: date, theme: theme, locale: locale)
    }

    /// Exposed so a test can check what a share would actually carry.
    func exported() async throws -> Data {
        try await pngData()
    }

    private func pngData() async throws -> Data {
        guard let data = await render()?.pngData() else {
            throw SkyCardError.couldNotRender
        }
        return data
    }
}

enum SkyCardError: Error {
    case couldNotRender
}
