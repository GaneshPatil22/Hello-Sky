import Foundation

/// Where the sun is, and when it rises and sets.
///
/// Positions come from the low-precision solar model: good to roughly a minute
/// of arc, which is far below what a sky gradient or a sunrise time needs.
public enum Sun {
    /// The elevation counted as sunrise or sunset.
    ///
    /// Below zero because atmospheric refraction lifts the sun's image by about
    /// 34 arcminutes and the event is timed on the upper limb, not the centre.
    public static let horizonElevation = -0.833

    /// The sun's zenith point at `date`.
    public static func subsolarPoint(at date: Date) -> SubsolarPoint {
        let n = JulianDay(date).daysSinceJ2000

        let meanLongitude = Angle.normalizedDegrees(Series.meanLongitude + Series.meanLongitudeRate * n)
        let meanAnomaly = Angle.radians(
            fromDegrees: Angle.normalizedDegrees(Series.meanAnomaly + Series.meanAnomalyRate * n)
        )
        let eclipticLongitude = Angle.radians(fromDegrees: meanLongitude
            + Series.equationOfCentre1 * sin(meanAnomaly)
            + Series.equationOfCentre2 * sin(2 * meanAnomaly))
        let obliquity = Angle.radians(fromDegrees: Series.obliquity + Series.obliquityRate * n)

        let declination = asin(sin(obliquity) * sin(eclipticLongitude))
        let rightAscension = Angle.degrees(
            fromRadians: atan2(cos(obliquity) * sin(eclipticLongitude), cos(eclipticLongitude))
        )
        let equationOfTime = Angle.signedDegrees(meanLongitude - rightAscension)

        let hoursUTC = date.timeIntervalSince1970
            .truncatingRemainder(dividingBy: JulianDay.Constants.secondsPerDay)
            .addingDayIfNegative / Series.secondsPerHour
        let longitude = Angle.signedDegrees(
            -Series.degreesPerHour * (hoursUTC - Series.noonHour) - equationOfTime
        )

        return SubsolarPoint(declination: Angle.degrees(fromRadians: declination), longitude: longitude)
    }

    /// The sun seen from `coordinate` at `date`.
    public static func position(at date: Date, from coordinate: Coordinate) -> SunPosition {
        let subsolar = subsolarPoint(at: date)
        let latitude = Angle.radians(fromDegrees: coordinate.latitude)
        let declination = Angle.radians(fromDegrees: subsolar.declination)
        let hourAngleDegrees = Angle.signedDegrees(coordinate.longitude - subsolar.longitude)
        let hourAngle = Angle.radians(fromDegrees: hourAngleDegrees)

        let sinElevation = sin(latitude) * sin(declination)
            + cos(latitude) * cos(declination) * cos(hourAngle)
        let elevation = asin(sinElevation.clamped(to: -1...1))

        // Measured from south, then turned to run clockwise from north.
        let azimuthFromSouth = atan2(
            sin(hourAngle),
            cos(hourAngle) * sin(latitude) - tan(declination) * cos(latitude)
        )
        let azimuth = Angle.normalizedDegrees(Angle.degrees(fromRadians: azimuthFromSouth) + Angle.halfTurn)

        return SunPosition(
            elevation: Angle.degrees(fromRadians: elevation),
            azimuth: azimuth,
            hourAngle: hourAngleDegrees
        )
    }
}

extension Sun {
    /// Coefficients of the low-precision solar position model.
    enum Series {
        static let meanLongitude = 280.460
        static let meanLongitudeRate = 0.985_647_4
        static let meanAnomaly = 357.528
        static let meanAnomalyRate = 0.985_600_3
        static let equationOfCentre1 = 1.915
        static let equationOfCentre2 = 0.020
        static let obliquity = 23.439
        static let obliquityRate = -0.000_000_4

        static let degreesPerHour = 15.0
        static let noonHour = 12.0
        static let secondsPerHour = 3_600.0
    }
}

extension Double {
    /// Public because the renderer keeps its own ratios inside 0...1 too.
    public func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }

    /// Turns a negative remainder of a day's worth of seconds into its positive equivalent.
    var addingDayIfNegative: Double {
        self < 0 ? self + JulianDay.Constants.secondsPerDay : self
    }
}
