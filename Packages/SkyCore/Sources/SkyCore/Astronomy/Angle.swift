import Foundation

/// Shared conversions for the astronomy code, which works in degrees at its
/// boundaries and radians inside.
enum Angle {
    static let degreesPerRadian = 180 / Double.pi
    static let radiansPerDegree = Double.pi / 180
    static let fullTurn = 360.0
    static let halfTurn = 180.0

    static func radians(fromDegrees degrees: Double) -> Double {
        degrees * radiansPerDegree
    }

    static func degrees(fromRadians radians: Double) -> Double {
        radians * degreesPerRadian
    }

    /// Wraps to `0..<360`.
    static func normalizedDegrees(_ degrees: Double) -> Double {
        let wrapped = degrees.truncatingRemainder(dividingBy: fullTurn)
        return wrapped < 0 ? wrapped + fullTurn : wrapped
    }

    /// Wraps to `-180..<180`, which is what longitudes and the equation of time need.
    static func signedDegrees(_ degrees: Double) -> Double {
        normalizedDegrees(degrees + halfTurn) - halfTurn
    }
}
