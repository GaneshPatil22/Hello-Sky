# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Hello Sky is an iOS app (SwiftUI) that shows a 3D globe of the people you care about and turns into their live sky when you tap one.

**The repository is currently a bare Xcode template** — `Hello Sky/MyApp.swift` and `Hello Sky/ContentView.swift`, nothing else. None of the architecture below exists in code yet. `hello-sky-plan.md` is the design document and the source of truth for scope, phasing, and the rules in this file; read the relevant section before building anything new, and update it when a decision changes.

## Commands

The project name contains a space, so quote every path and scheme.

```bash
make build          # build the app for the simulator
make test           # all package tests, then the app build
make test-packages  # package tests only — seconds, no simulator

# One package, or one suite inside it
swift test --package-path Packages/SkyCore
swift test --package-path Packages/SkyCore --filter CoordinateTests
```

Prefer `swift test --package-path` over `xcodebuild test` for logic work — it runs in seconds with no simulator. Note that it builds for the **host (macOS)**, not iOS, so anything touching an iOS-only API needs an `xcodebuild -destination 'platform=iOS Simulator,...'` run instead.

Packages use `swift-tools-version: 6.4`, which is what makes the `.iOS(.v27)` platform value available. `SkyUI` and `Globe` set `.defaultIsolation(MainActor.self)` to match the app target; `SkyCore` and `SkyData` stay nonisolated so their work can run off the main actor.

Tests use **Swift Testing** (`import Testing`, `@Suite`, `@Test`, `#expect`), not XCTest.

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

**Quality tiers.** The globe and sky pick high/medium/low automatically and drop texture size, the cloud layer, and glow when the frame rate falls. The baseline device is an **iPhone 12 Pro on iOS 27**, which is available for physical testing. Profile there, not only in the simulator.

## Coding practices

Use the `swiftui-pro` skill whenever writing or reviewing Swift/SwiftUI in this repo.

- **SOLID and DRY, applied with judgment.** One type, one job. Depend on protocols at the seams that matter (`WeatherProvider`, `ThemeRegistry`) and on concrete types everywhere else. Extract a shared helper on the second real duplication, not the first — two things that merely look alike often diverge later.
- **Pure functions by default.** All astronomy, status, overlap, and theme resolution are `(input) -> output` with no clocks, no network, no globals. `Date` is a parameter, never `Date()` read inside the function. This is what makes `SkyCore` testable in seconds and the sky renderer reproducible in snapshots.
- **Push side effects to the edges.** Network, disk, SwiftData, notifications, and haptics live in `SkyData` or in view models — never inside a view body, a renderer, or a `SkyCore` type.
- **No hard-coded values.** Tuning numbers, durations, sizes, thresholds, colors, keys, and URLs go in a named constant (a `Constants` enum, or the `Theme` data for anything visual). A literal that appears in a view body should be a named value that says what it means. Strings shown to the user belong in the String Catalog.
- **Do not over-engineer.** No protocol with one implementation that will never gain a second, no generic abstraction written for an imagined future, no manager or coordinator layer added before something needs coordinating. The seams above are specified because the plan proves they will be swapped; everything else starts concrete and gets abstracted when a second case actually arrives.

Balance is the rule: these principles serve readable, testable code, and when one of them starts producing ceremony instead, stop applying it.

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

`swiftui-pro` (in `.agents/skills/`, symlinked into `.claude/skills/`) reviews Swift and SwiftUI for modern API usage, accessibility, and performance. Its `references/` folder covers views, data flow, navigation, performance, and localization.

`/commit` (in `.claude/commands/`) writes a commit as title, one-line description, and exactly three bullets, with no AI attribution trailer.
