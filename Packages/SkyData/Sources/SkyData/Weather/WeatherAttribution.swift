import Foundation

/// The credit a source requires to be shown beside its data.
///
/// Carried by the provider rather than hard-coded in a screen, so changing
/// source changes the credit automatically and the app cannot show the wrong one.
public struct WeatherAttribution: Hashable, Sendable {
    public let text: String
    public let url: URL?

    public init(text: String, url: URL? = nil) {
        self.text = text
        self.url = url
    }

    /// Shown when a reading was computed here rather than fetched.
    public static let estimated = WeatherAttribution(text: "Estimated from sun position")
}
