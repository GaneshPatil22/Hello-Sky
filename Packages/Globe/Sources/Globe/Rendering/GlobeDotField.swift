import Foundation
import SkyCore
import simd

/// The points the globe's continents are drawn from.
///
/// Scattered evenly over the sphere by the golden angle, then kept only where
/// the mask says there is land. Even spacing is the whole point: a latitude and
/// longitude grid bunches up at the poles and looks wrong.
public enum GlobeDotField {
    /// Land points at the highest quality, computed once.
    public static let points: [SIMD3<Float>] = makePoints(count: Density.high)

    /// The subset a quality tier draws. Lower tiers take every nth point, which
    /// thins the continents evenly rather than cropping them.
    public static func points(for quality: GlobeQuality) -> ArraySlice<SIMD3<Float>> {
        points.prefix(count(for: quality))
    }

    static func count(for quality: GlobeQuality) -> Int {
        switch quality {
        case .high: points.count
        case .medium: points.count / 2
        case .low: points.count / 4
        }
    }

    static func makePoints(count: Int) -> [SIMD3<Float>] {
        // The golden angle: successive points land in the gaps left by the
        // previous ones, which is what gives an even scatter.
        let goldenAngle = Double.pi * (3 - 5.squareRoot())
        var found: [SIMD3<Float>] = []
        found.reserveCapacity(count / 3)

        for index in 0..<count {
            let y = 1 - 2 * (Double(index) + 0.5) / Double(count)
            let radius = (1 - y * y).squareRoot()
            let theta = Double(index) * goldenAngle
            let x = cos(theta) * radius
            let z = sin(theta) * radius

            let latitude = asin(y) * 180 / .pi
            let longitude = atan2(x, z) * 180 / .pi
            if LandMask.isLand(latitude: latitude, longitude: longitude) {
                found.append(SIMD3(Float(x), Float(y), Float(z)))
            }
        }
        return found
    }
}

extension GlobeDotField {
    enum Density {
        /// Points scattered before the land test; about a third survive.
        static let high = 15_000
    }
}
