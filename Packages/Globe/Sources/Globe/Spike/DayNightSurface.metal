#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

// Spike: blends a day colour into a night colour across the terminator, with
// the sun direction supplied as a custom vector. If this compiles and runs on
// iOS, the globe is a RealityKit CustomMaterial; if not, the same maths moves
// to a Metal view.
[[visible]]
void helloSkyDayNightSurface(realitykit::surface_parameters params)
{
    float3 normal = normalize(params.geometry().normal());
    float3 sun = normalize(params.uniforms().custom_parameter().xyz);

    float lit = saturate(dot(normal, sun) * 4.0 + 0.5);

    half3 day = half3(0.18, 0.42, 0.78);
    half3 night = half3(0.02, 0.03, 0.09);
    half3 colour = mix(night, day, half(lit));

    params.surface().set_base_color(colour);
    params.surface().set_roughness(half(1.0));
    params.surface().set_metallic(half(0.0));
}
