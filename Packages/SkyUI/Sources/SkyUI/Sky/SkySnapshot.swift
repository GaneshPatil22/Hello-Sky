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
    /// through the air, and fades both as the sun climbs and as it sets.
    ///
    /// Both ends fade. An earlier version cut the glow off below the horizon
    /// while it was still at full strength just above it, so the halo — and
    /// everything coloured from it — snapped as the sun crossed that line.
    static func sunGlow(sunElevation: Double, cloud: Double) -> Double {
        let rise = Self.ramp(sunElevation, from: Thresholds.glowFullyFadedAbove, to: 0)
        let set = Self.ramp(sunElevation, from: Thresholds.glowStops, to: 0)
        return rise * set * (1 - cloud * Thresholds.cloudDimsGlow)
    }

    /// The colour the screen's controls take from the sky.
    ///
    /// The sky's own hue, brought up to a usable brightness. Taking the hue is
    /// the point: a dawn gives a warm tan, a midday a cool near-white, a dusk
    /// a violet. Blending towards one fixed warm tone, as this did at first,
    /// only ever made the accent lighter or darker.
    ///
    /// The horizon carries the day's colour more strongly than the top of the
    /// sky, so the accent is taken from there and leant towards the glow when
    /// the sun is near the horizon.
    /// Follows whatever is lighting the place: the sky through the day, the
    /// low sun at dawn and dusk, and the moon once it is dark. So a midday is
    /// cool, a sunrise is warm, and a night is warm in a different way again.
    public var accent: SkyColor {
        let base = gradient.horizon.blended(towards: gradient.top, amount: Thresholds.accentFromTop)
        let lit = base.blended(towards: Thresholds.accentGlow, amount: sunGlow * Thresholds.accentGlowPull)
        let byNight = lit.blended(
            towards: Thresholds.accentMoonlight,
            amount: starVisibility * Thresholds.accentMoonPull
        )
        return byNight.asAccent()
    }

    /// How far up the frame something sits, from its elevation.
    ///
    /// Stops short of the top edge rather than running to it: near the equator
    /// the midday sun is almost overhead, and a mapping that saturates puts it
    /// half off the screen.
    public static func verticalPosition(elevation: Double, in height: Double) -> Double {
        let up = (elevation / Thresholds.elevationAtTop).clamped(to: 0...1)
        let horizon = height * Thresholds.horizonFraction
        let ceiling = height * Thresholds.skyCeilingFraction
        return horizon - (horizon - ceiling) * up
    }

    /// Where something sits across the frame, from its hour angle.
    ///
    /// Not from azimuth: near the equator the azimuth barely moves all morning
    /// and then swings through half a turn within minutes of noon, so a sun
    /// placed by it appears to climb and fall in a straight line. The hour
    /// angle advances evenly with the clock at every latitude, which is what
    /// traces an arc.
    public static func across(hourAngle: Double) -> Double {
        (0.5 + hourAngle / Thresholds.hourAngleAcrossFrame).clamped(to: 0...1)
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
        /// Degrees of hour angle spanning the whole width, so six hours either
        /// side of noon fills the frame.
        public static let hourAngleAcrossFrame = 360.0
        /// Straight overhead, which happens daily in the tropics.
        public static let elevationAtTop = 90.0
        /// Where the horizon sits in the frame.
        public static let horizonFraction = 0.78
        /// The highest the sun or moon is drawn, leaving room for the disc.
        public static let skyCeilingFraction = 0.13
        /// How much of the sky's upper colour the accent borrows.
        public static let accentFromTop = 0.25
        /// Low sun lends its warmth to the accent, which is what makes a
        /// sunrise feel different from a midday.
        public static let accentGlowPull = 0.45
        public static let accentGlow = SkyColor(hex: 0xFFC27A)
        /// Once the stars are out the moon is what lights the place, and its
        /// light is warmer than the sky it crosses.
        public static let accentMoonPull = 0.8
        public static let accentMoonlight = SkyColor(hex: 0xD8C2A0)
        /// By this height the halo has gone.
        public static let glowFullyFadedAbove = 25.0
    }
}
