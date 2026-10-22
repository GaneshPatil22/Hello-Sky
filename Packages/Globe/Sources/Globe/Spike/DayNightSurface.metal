#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

// The globe's surface: day on the side facing the sun, night on the other, with
// a soft line between and a lit rim where the atmosphere would be.
//
// The sun arrives as a world-space direction in the custom parameter, and the
// normal is taken from the world position rather than the interpolated normal,
// so both are in the same frame no matter how far the Earth has turned.
[[visible]]
void helloSkyDayNightSurface(realitykit::surface_parameters params)
{
    float3 normal = normalize(params.geometry().world_position());
    float3 sun = normalize(params.uniforms().custom_parameter().xyz);
    float3 toCamera = normalize(params.geometry().view_direction());

    // Multiplying before saturating is what makes the terminator a band a few
    // degrees wide rather than a hard edge.
    float lit = saturate(dot(normal, sun) * 3.0 + 0.5);

    half3 ocean = half3(0.055, 0.14, 0.33);
    half3 daylight = half3(0.16, 0.42, 0.78);
    half3 night = half3(0.016, 0.027, 0.072);
    half3 surface = mix(ocean, daylight, half(lit));
    half3 colour = mix(night, surface, half(lit));

    // City lights: only on the night side, strongest well away from the line.
    float nightness = saturate(1.0 - lit * 1.6);
    colour += half3(0.34, 0.26, 0.13) * half(nightness * 0.22);

    // Atmosphere: brightest where the surface turns away from the viewer.
    float rim = pow(saturate(1.0 - abs(dot(normal, toCamera))), 3.0);
    float sunlitRim = rim * saturate(dot(normal, sun) + 0.4);
    colour += half3(0.35, 0.60, 1.0) * half(sunlitRim * 0.85);

    params.surface().set_base_color(colour);
    // Emissive too: the scene carries no lights, so a lit-only colour would
    // render black.
    params.surface().set_emissive_color(colour);
    params.surface().set_roughness(half(1.0));
    params.surface().set_metallic(half(0.0));
}
