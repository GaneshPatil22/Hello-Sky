# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Hello Sky is an iOS app (SwiftUI) that shows a 3D globe of the people you care about and turns into their live sky when you tap one.

**The repository is currently a bare Xcode template** — `Hello Sky/MyApp.swift` and `Hello Sky/ContentView.swift`, nothing else. None of the architecture below exists in code yet. `hello-sky-plan.md` is the design document and the source of truth for scope, phasing, and the rules in this file; read the relevant section before building anything new, and update it when a decision changes.

## Commands

The project name contains a space, so quote every path and scheme.

```bash
# Build
xcodebuild -project "Hello Sky.xcodeproj" -scheme "Hello Sky" \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Test (no test targets exist yet — this fails until Phase 0 adds them)
xcodebuild -project "Hello Sky.xcodeproj" -scheme "Hello Sky" \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Single test, once the local packages exist
swift test --package-path Packages/SkyCore --filter SunPositionTests/testPolarNight
```

Local Swift packages (`SkyCore`, `SkyData`, `SkyUI`, `Globe`) are meant to be testable with `swift test` without launching the app — prefer that over `xcodebuild test` for logic work.

The `.xcodeproj` uses synchronized file groups (`objectVersion = 90`). **Adding a file to the `Hello Sky/` folder adds it to the target automatically** — never hand-edit `project.pbxproj` to register sources.

## Architecture rules

These are design constraints, not descriptions of existing code. They exist so later phases can swap implementations without touching screens.

**Module split.** The app is divided into local packages, each with its own tests and mock data:

| Module | Owns | Depends on |
| --- | --- | --- |
| `SkyCore` | Sun/moon math, time zones, awake status, overlap windows, plain data models | Foundation only |
| `SkyData` | Weather providers, caching, SwiftData models | `SkyCore` |
| `SkyUI` | Sky renderer, `Theme`, shared components | `SkyCore` |
| `Globe` | RealityKit scene, shaders, textures | `SkyCore`, `SkyUI` |
| `HelloSky` (app) | Navigation, screens, globe-to-sky transition | all of the above |
| `HelloSkyWidgets` | Widgets and timelines | `SkyCore`, `SkyData`, `SkyUI` |

`SkyCore` must never import SwiftUI or UIKit — it has to stay testable in seconds.

**Weather goes through two seams, always.** Screens and widgets see only `SkyWeather`, our own small model. Provider types, JSON shapes, units, and vendor condition names never escape a provider.

- `WeatherProvider` (protocol) is the seam for *sources*: `MockWeatherProvider`, `OpenMeteoProvider` (development), `WeatherKitProvider` (release), and a future `SharedCacheProvider`. Each maps its own data into `SkyWeather` and supplies its own attribution string, so the app shows the correct credit automatically.
- `WeatherRepository` is the seam for *behavior*: on-device cache, in-flight request dedupe, daily call budget, and a fallback chain of cache → clear-sky model computed by `SkyCore`.

Switching weather source or adding caching must not change a single screen. The same contract tests run against every provider.

**A look is data, not code.** `ThemeRegistry` holds the three v1 looks (Realistic, Dusk, Ink) as sky color keyframes, globe shader settings, accent color, star tint, icon name, and optional texture overrides. The picker, settings, and all screens read from the registry. Adding a look = one data file + one icon, with no look-specific code in any screen.

**Privacy by design.** No accounts, no server of our own, no ads, no analytics SDKs. The people list stays on the device; location is optional (My sky works from a typed city).

**Latest iOS only.** Minimum is iOS 27, matching `IPHONEOS_DEPLOYMENT_TARGET`. This is deliberate: `RealityView`, `MeshGradient`, `Tab`, `glassEffect`, and on-device AI captions are all available unconditionally. Do not add `if #available` checks or fallback paths for older systems — one code path is the point.

**Quality tiers.** The globe and sky pick high/medium/low automatically and drop texture size, the cloud layer, and glow when the frame rate falls. The baseline is the oldest iPhone that runs iOS 27 — confirm which model that is before Phase 5.

## Correctness traps

Time and astronomy edge cases belong in tests from the first commit: half-hour and 45-minute zones (India, Nepal), the date line, DST changes landing on different dates per country, polar day and night where the sun never rises or sets, a traveler whose phone changes time zone, and leap day. Sunrise/sunset fixtures are generated from the `astral` library with a two-minute tolerance.

## Build settings

Settled deliberately — do not revert these to template defaults:

- `IPHONEOS_DEPLOYMENT_TARGET = 27.0` — latest iOS only, no back-compatibility paths.
- `SWIFT_VERSION = 6.0` — Swift 6 language mode, with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES` already set. New code must be concurrency-clean; do not silence data-race errors with `@unchecked Sendable` or `nonisolated(unsafe)` without a written reason.
- `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"` and `TARGETED_DEVICE_FAMILY = "1"` — iPhone only. macOS, visionOS, tvOS, watchOS, DriverKit deployment targets and the iPad orientation key were removed from the template.

## Attribution requirements

Weather and texture sources carry mandatory credits — Apple Weather mark plus legal link beside the data, "Weather data by Open-Meteo.com" in development builds, "Contains modified EUMETSAT data" for clouds, NASA for Blue/Black Marble textures. Each provider supplies its own attribution text so this stays automatic. See section 6 of the plan.

## Skills

`swiftui-pro` (in `.agents/skills/`, symlinked into `.claude/skills/`) reviews Swift and SwiftUI for modern API usage and performance. Invoke it when writing or reviewing SwiftUI in this repo.
