import Foundation

/// The moon's phase and approximate position.
public enum Moon {
    public static func phase(at date: Date) -> MoonPhase {
        let daysSinceReferenceNewMoon = JulianDay(date).value - Series.referenceNewMoon
        var fraction = (daysSinceReferenceNewMoon / Series.synodicMonth).truncatingRemainder(dividingBy: 1)
        if fraction < 0 { fraction += 1 }
        return MoonPhase(
            fraction: fraction,
            illumination: (1 - cos(2 * .pi * fraction)) / 2
        )
    }

    /// The moon seen from `coordinate` at `date`, to within a few degrees.
    public static func position(at date: Date, from coordinate: Coordinate) -> MoonPosition {
        let subsolar = Sun.subsolarPoint(at: date)
        let phase = phase(at: date)
        let daysSinceReferenceNewMoon = JulianDay(date).value - Series.referenceNewMoon

        // The moon trails the sun across the sky by its phase: new moon rises
        // with the sun, full moon opposes it.
        let hourAngle = Angle.radians(fromDegrees: coordinate.longitude - subsolar.longitude)
            - phase.fraction * 2 * .pi
        // Declination swings through the ecliptic tilt over a tropical month.
        let declination = Angle.radians(fromDegrees: Series.maximumDeclination)
            * sin(2 * .pi * daysSinceReferenceNewMoon / Series.tropicalMonth)
        let latitude = Angle.radians(fromDegrees: coordinate.latitude)

        let sinElevation = sin(latitude) * sin(declination)
            + cos(latitude) * cos(declination) * cos(hourAngle)
        let elevation = asin(sinElevation.clamped(to: -1...1))
        let azimuthFromSouth = atan2(
            sin(hourAngle),
            cos(hourAngle) * sin(latitude) - tan(declination) * cos(latitude)
        )

        return MoonPosition(
            elevation: Angle.degrees(fromRadians: elevation),
            azimuth: Angle.normalizedDegrees(Angle.degrees(fromRadians: azimuthFromSouth) + Angle.halfTurn)
        )
    }
}

extension Moon {
    enum Series {
        /// Mean length of one new moon to the next, in days.
        static let synodicMonth = 29.530_588_853
        /// Mean time for the moon to return to the same declination, in days.
        static let tropicalMonth = 27.321_582
        /// Julian day of a reference new moon, 2000-01-06.
        static let referenceNewMoon = 2_451_550.1
        /// How far the moon's declination swings either side of the equator.
        static let maximumDeclination = 23.4
    }
}
