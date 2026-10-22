import Foundation
import SkyCore
import simd

/// Turning places on Earth into points on a unit sphere, and back.
///
/// The convention matches the prototype's: +Y is the north pole, and longitude
/// runs eastward from the +Z meridian.
public enum GlobeGeometry {
    public static func vector(for coordinate: Coordinate) -> SIMD3<Float> {
        let latitude = Float(coordinate.latitude * .pi / 180)
        let longitude = Float(coordinate.longitude * .pi / 180)
        return SIMD3(
            cos(latitude) * sin(longitude),
            sin(latitude),
            cos(latitude) * cos(longitude)
        )
    }

    public static func coordinate(for vector: SIMD3<Float>) -> Coordinate {
        let unit = simd_normalize(vector)
        let latitude = asin(max(-1, min(1, unit.y)))
        let longitude = atan2(unit.x, unit.z)
        return Coordinate(
            latitude: Double(latitude) * 180 / .pi,
            longitude: Double(longitude) * 180 / .pi
        )
    }

    /// Where the sun is, as a direction from the centre of the Earth.
    ///
    /// It is the subsolar point turned into a vector: the shader lights the
    /// globe by how closely each point's normal agrees with this.
    public static func sunDirection(at date: Date) -> SIMD3<Float> {
        vector(for: Sun.subsolarPoint(at: date).coordinate)
    }

    /// How much daylight a point gets, from 0 at the far side to 1 facing the sun.
    ///
    /// The same quantity the shader computes, exposed so tests can check the
    /// day/night line against `SkyCore` rather than against a screenshot.
    public static func daylight(at coordinate: Coordinate, date: Date) -> Double {
        Double(simd_dot(vector(for: coordinate), sunDirection(at: date)))
    }
}
