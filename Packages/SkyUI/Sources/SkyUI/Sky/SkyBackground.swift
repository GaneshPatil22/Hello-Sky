import SkyCore
import SwiftUI

/// The sky's colour field.
///
/// A mesh rather than a linear gradient so the band near the horizon can bulge
/// towards the sun's side, which is what makes a sunrise look like it has a
/// direction rather than being a stripe.
struct SkyBackground: View {
    let snapshot: SkySnapshot

    var body: some View {
        MeshGradient(width: Mesh.columns, height: Mesh.rows, points: points, colors: colors)
    }

    /// A 3×3 grid, with the middle row pulled down towards the horizon on the
    /// side the sun is on.
    private var points: [SIMD2<Float>] {
        let bias = Float(horizonBias)
        let middle = Float(Mesh.middleRow)
        return [
            SIMD2(0, 0), SIMD2(0.5, 0), SIMD2(1, 0),
            SIMD2(0, middle + bias), SIMD2(0.5, middle), SIMD2(1, middle - bias),
            SIMD2(0, 1), SIMD2(0.5, 1), SIMD2(1, 1),
        ]
    }

    private var colors: [Color] {
        let top = snapshot.gradient.top
        let horizon = snapshot.gradient.horizon
        let middle = top.blended(towards: horizon, amount: Mesh.middleBlend)
        // The horizon row warms towards the glow where the sun is.
        let lit = horizon.blended(towards: top, amount: -Mesh.litLift * snapshot.sunGlow)
        return [
            top.color, top.color, top.color,
            middle.color, middle.color, middle.color,
            horizon.color, lit.color, horizon.color,
        ]
    }

    /// Which side the sun is on, as a small shift of the middle row.
    private var horizonBias: Double {
        let fromCentre = (snapshot.sun.azimuth - 180) / 180
        return fromCentre.clamped(to: -1...1) * Mesh.maximumBias
    }
}

extension SkyBackground {
    private enum Mesh {
        static let columns = 3
        static let rows = 3
        static let middleRow = 0.55
        static let middleBlend = 0.55
        static let maximumBias = 0.08
        static let litLift = 0.25
    }
}
