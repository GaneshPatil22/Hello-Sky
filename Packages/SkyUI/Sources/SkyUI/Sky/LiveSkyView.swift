import SkyCore
import SwiftUI

/// A sky that moves: clouds drift, stars twinkle, rain falls.
///
/// Honours Reduce Motion by rendering the same view with its motion frozen,
/// which is a still sky rather than a different one.
public struct LiveSkyView: View {
    let place: Place
    let weather: SkyWeather
    let date: Date

    @Environment(\.theme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(place: Place, weather: SkyWeather, date: Date = .now) {
        self.place = place
        self.weather = weather
        self.date = date
    }

    public var body: some View {
        if reduceMotion {
            SkyView(snapshot: snapshot, motion: 0)
        } else {
            TimelineView(.animation(minimumInterval: Animation.minimumInterval)) { context in
                SkyView(snapshot: snapshot, motion: context.date.timeIntervalSince(date))
            }
        }
    }

    private var snapshot: SkySnapshot {
        SkySnapshot(place: place, date: date, weather: weather, theme: theme)
    }
}

extension LiveSkyView {
    private enum Animation {
        /// Everything that moves here drifts; thirty frames a second is plenty
        /// and leaves headroom for the globe.
        static let minimumInterval = 1.0 / 30
    }
}
