import Foundation
import SkyCore

/// Everything needed to draw one sky, worked out from place, time, weather and look.
///
/// A pure value: the same four inputs always give the same snapshot, which is
/// what makes the gallery and the snapshot tests meaningful. Nothing here draws.
public struct SkySnapshot: Hashable, Sendable {
    public let sun: SunPosition
    public let moon: MoonPosition
    public let moonPhase: MoonPhase
    public let solarPhase: SolarPhase
    public let theme: Theme

    /// The background colours for this sun elevation, from the look's table.
    public let gradient: SkyGradient
    /// How visible the stars are, from 0 in daylight to 1 in full dark.
    public let starVisibility: Double
    public let cloudCover: CloudCover
    /// Rain intensity from 0 to 1.
    public let rain: Double
    /// How strong the sun's halo is, from 0 to 1.
    public let sunGlow: Double
    /// Seeded from the place, so a city's stars and clouds are always its own.
    public let seed: UInt64

    public init(place: Place, date: Date, weather: SkyWeather, theme: Theme) {
        let sun = Sun.position(at: date, from: place.coordinate)
        self.sun = sun
        self.moon = Moon.position(at: date, from: place.coordinate)
        self.moonPhase = Moon.phase(at: date)
        self.solarPhase = sun.phase
        self.theme = theme
        self.gradient = theme.sky.gradient(forSunElevation: sun.elevation)
        self.cloudCover = weather.cloudCover
        self.rain = weather.rain
        self.starVisibility = Self.starVisibility(sunElevation: sun.elevation, cloud: weather.cloudCover.total)
        self.sunGlow = Self.sunGlow(sunElevation: sun.elevation, cloud: weather.cloudCover.total)
        self.seed = place.id.stableHash
    }
}

extension SkySnapshot {
    /// Whether anything of the moon would be seen: up, and not a bare sliver.
    public var isMoonVisible: Bool {
        moon.isVisible && moonPhase.illumination > Thresholds.faintestVisibleMoon
    }

    /// How strongly to draw the moon.
    ///
    /// Not the same as `starVisibility`: the moon is plainly visible in a
    /// daylit sky, just paler, whereas stars are not visible at all. Tying the
    /// two together made the moon a dark hole at dusk, because its lit side
    /// faded while its shadow did not.
    public var moonVisibility: Double {
        guard isMoonVisible else { return 0 }
        let daylight = Self.ramp(sun.elevation,
                                 from: SolarPhase.Thresholds.blueHour,
                                 to: Thresholds.moonFaintestAbove)
        return Thresholds.moonInDaylight
            + (1 - Thresholds.moonInDaylight) * (1 - daylight)
    }

    /// Stars appear once the sun is well down, and clouds hide them.
    static func starVisibility(sunElevation: Double, cloud: Double) -> Double {
        let darkness = Self.ramp(
            sunElevation,
            from: SolarPhase.Thresholds.blueHour,
            to: SkyPalette.Elevation.astronomicalTwilight
        )
        return darkness * (1 - cloud * Thresholds.cloudHidesStars)
    }

    /// The halo is strongest at the horizon, where the light travels furthest
    /// through the air, and fades as the sun climbs.
    static func sunGlow(sunElevation: Double, cloud: Double) -> Double {
        guard sunElevation > Thresholds.glowStops else { return 0 }
        let height = Self.ramp(sunElevation, from: Thresholds.glowFullyFadedAbove, to: Thresholds.glowStops)
        return height * (1 - cloud * Thresholds.cloudDimsGlow)
    }

    /// 0 at `from`, 1 at `to`, linear between, whichever direction they run.
    static func ramp(_ value: Double, from: Double, to: Double) -> Double {
        guard from != to else { return value >= to ? 1 : 0 }
        return ((value - from) / (to - from)).clamped(to: 0...1)
    }

    public enum Thresholds {
        /// A sliver this thin is not worth drawing.
        public static let faintestVisibleMoon = 0.02
        /// Thick cloud removes almost every star, but not quite all.
        public static let cloudHidesStars = 0.95
        /// Overcast keeps some brightness around the sun's position.
        public static let cloudDimsGlow = 0.8
        /// Below this the sun is too far down to glow.
        public static let glowStops = -6.0
        /// How strongly the moon shows in full daylight.
        public static let moonInDaylight = 0.35
        /// The sun elevation by which the moon is at its palest.
        public static let moonFaintestAbove = 15.0
        /// By this height the halo has gone.
        public static let glowFullyFadedAbove = 25.0
    }
}
