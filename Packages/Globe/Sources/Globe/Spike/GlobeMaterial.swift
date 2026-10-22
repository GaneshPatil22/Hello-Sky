import Foundation
import Metal
import RealityKit
import SkyCore
import simd

/// The day/night material, built from the package's own Metal library.
///
/// The Phase 5 spike: RealityKit custom materials were untested on iOS in this
/// project, and everything else in the globe depends on them working. They do;
/// the Metal view fallback stays unused.
public enum GlobeMaterial {
    public enum Failure: Error {
        case noMetalDevice
        case shaderLibraryMissing(String)
    }

    /// Builds the material and points it at the sun.
    public static func dayNight(sunDirection: SIMD3<Float>) throws -> CustomMaterial {
        guard let device = MTLCreateSystemDefaultDevice() else { throw Failure.noMetalDevice }
        let library: any MTLLibrary
        do {
            library = try device.makeDefaultLibrary(bundle: Bundle.module)
        } catch {
            throw Failure.shaderLibraryMissing(error.localizedDescription)
        }

        let surface = CustomMaterial.SurfaceShader(named: Shader.surface, in: library)
        var material = try CustomMaterial(surfaceShader: surface, lightingModel: .unlit)
        material.custom.value = SIMD4(sunDirection, 0)
        return material
    }

    /// Updates an existing material as time moves, without rebuilding it.
    public static func update(_ material: inout CustomMaterial, sunDirection: SIMD3<Float>) {
        material.custom.value = SIMD4(sunDirection, 0)
    }

    enum Shader {
        static let surface = "helloSkyDayNightSurface"
    }
}
