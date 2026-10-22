# Progress

Live tracker for Hello Sky. Updated before every commit.

**Current phase:** Phase 0 — Foundation
**Last updated:** 2026-10-22
**Overall:** 0 of 9 phases complete · roughly 11 of 248–332 hours

```
Phase 0  █████████░  in progress
Phase 1  ░░░░░░░░░░  not started
Phase 2  ░░░░░░░░░░  not started
Phase 3  ░░░░░░░░░░  not started
Phase 4  ░░░░░░░░░░  not started
Phase 5  ░░░░░░░░░░  not started
Phase 6  ░░░░░░░░░░  not started
Phase 7  ░░░░░░░░░░  not started
Phase 8  ░░░░░░░░░░  not started
```

---

## Right now

**Working on:** Phase 0 foundation — everything except the device install is done. The theme system, fixtures, and widget extension are all in and tested.

**Next three things:**
1. Install on the iPhone 12 Pro with a free Apple ID, which closes Phase 0. *(Needs the device; the simulator cannot prove signing.)*
2. Start Phase 1: port `sunState`, `sunPos`, and `julian` from the web demo into `SkyCore`.
3. Generate sunrise and sunset fixtures from `astral` for the eight fixture cities.

**Blocked on:** the web demo HTML file is not in this repository. Phase 0 needs its dummy people for fixtures, and Phase 1 needs its JavaScript astronomy as the port reference.

---

## Phase 0 — Foundation

*Target 8–12 h · an empty but real project that builds, runs its tests, and holds the mock data later phases use.*

- [x] Xcode project with an app target
- [x] Build settings settled: iOS 27 minimum, Swift 6, iPhone only
- [x] Git repository with `.gitignore`
- [x] `CLAUDE.md` with architecture rules and coding conventions
- [x] `README.md` with run steps
- [x] Local Swift packages: `SkyCore`, `SkyData`, `SkyUI`, `Globe`
- [x] A test target in each package
- [x] Packages linked into the app target
- [x] `make test` runs every package's tests and builds the app
- [x] Empty widget extension target
- [x] `Theme` type and `ThemeRegistry` holding the three looks
- [x] Fixtures folder with the demo's seven dummy people, plus a half-hour zone
- [ ] Verify: app installs on the iPhone 12 Pro with a free Apple ID

**Done when:** a fresh clone builds and passes all tests with one command, and a test look added only through the registry appears in the look picker.

## Phase 1 — Sky engine

*Target 20–28 h · all astronomy and time logic proven by unit tests before any screen exists.*

- [ ] Sun elevation, azimuth, and subsolar point
- [ ] Sunrise and sunset search, including polar day and night
- [ ] Moon phase and rough moon position
- [ ] Local-time helpers built on `TimeZone`
- [ ] Awake-status rules
- [ ] Best-overlap window finder
- [ ] Fixtures generated from `astral`, two-minute tolerance
- [ ] Edge-case tests: half-hour and 45-minute zones, date line, DST, polar day/night, leap day
- [ ] Performance check: next-event search fast enough to call every second

**Done when:** all tests pass and the package imports no UI framework.

## Phase 2 — People and storage

*Target 20–28 h · add, edit, and remove people with correct local time and call status.*

- [ ] SwiftData model for a person
- [ ] City search with MapKit local search
- [ ] Bundled list of ~200 cities for offline use and tests
- [ ] Debug seeding from mock fixtures
- [ ] Status and overlap computed by `SkyCore`
- [ ] Tests: model mapping, schema migration, in-memory store, UI test adding Tokyo

**Done when:** people survive a relaunch and the list shows correct times for every test city.

## Phase 3 — Weather layer

*Target 20–28 h · any screen can ask for a place's weather and always get an answer.*

- [ ] `SkyWeather` model and `WeatherProvider` protocol
- [ ] `MockWeatherProvider` reading fixtures
- [ ] `OpenMeteoProvider` with its credit line
- [ ] `WeatherRepository`: cache, request sharing, daily budget, clear-sky fallback
- [ ] Provider choice by build configuration
- [ ] Contract tests running the same assertions on every provider
- [ ] Stub `SharedCacheProvider` proving a new source needs no screen changes
- [ ] Debug screen listing weather for every person

**Done when:** with the network off, every person still shows a weather value, and switching providers needs no screen changes.

## Phase 4 — Sky renderer

*Target 35–45 h · a sky that is a pure function of place, time, weather, and look.*

- [ ] `SkyView` with `TimelineView` and `Canvas`
- [ ] Stars, clouds, moon with real phase, hills, rain
- [ ] `MeshGradient` atmosphere and optional Metal glow shader
- [ ] Seeded randomness so previews and snapshots stay stable
- [ ] Debug gallery: times × weather × looks
- [ ] Snapshot tests for ~12 fixed cases
- [ ] Still-frame path for Reduce Motion
- [ ] Frame-time profiling on the iPhone 12 Pro

**Done when:** the gallery looks right for four cities at six times of day, and the time slider changes the sky smoothly.

## Phase 5 — Globe

*Target 46–63 h · the realistic globe, working on its own before it joins the app.*

- [ ] **Spike first:** textured sphere with a custom day/night material in a throwaway project
- [ ] Day, night, cloud, and specular textures (4096×2048, mipmapped)
- [ ] Day/night shader driven by `SkyCore` sun direction
- [ ] Atmosphere glow
- [ ] Orbit dragging with inertia and slow auto-rotation
- [ ] People markers projected 3D→screen with tap detection
- [ ] Arcs between people
- [ ] Three looks as shader settings
- [ ] Automatic quality tiers with manual override
- [ ] Tests: sun direction matches `SkyCore`, day/night line at zero elevation, solstice and equinox checks, texture memory

**Done when:** a test slider moves the day/night line correctly and the globe stays smooth while dragging on the iPhone 12 Pro.

## Phase 6 — App flow and the signature transition

*Target 44–56 h · the whole flow running on the real engine.*

- [ ] Navigation state machine
- [ ] The zoom-and-reveal transition (camera move plus circular mask)
- [ ] One shared time model with offset and play
- [ ] Their sky and My sky screens
- [ ] Share card through `ImageRenderer`
- [ ] Add-person, looks, and settings sheets
- [ ] About and credits screen
- [ ] Tests: state machine, UI open/close, Reduce Motion path, 50× open/close leak check

**Done when:** every flow works with real astronomy, mock weather, and the real globe.

## Phase 7 — Widgets and alerts

*Target 25–32 h · widgets and notifications from the same data as the app.*

- [ ] **Before starting:** enrol in the Apple Developer Program
- [ ] Shared store in an App Group container
- [ ] WidgetKit timeline provider built from `SkyCore`
- [ ] Small, medium, and Lock Screen widgets
- [ ] Local notifications for sunrise and sunset
- [ ] Rolling notification window under the 64 pending cap
- [ ] Tapping a widget or notification opens that person's sky

**Done when:** a widget shows the right time and status hours later without opening the app.

## Phase 8 — Polish, WeatherKit, and TestFlight

*Target 30–40 h · a release candidate on real weather, in testers' hands.*

- [ ] App ID with WeatherKit capability and key
- [ ] `WeatherKitProvider` with Apple Weather attribution
- [ ] Open-Meteo excluded from Release builds
- [ ] Three-screen onboarding
- [ ] Main icon plus three alternate icons
- [ ] Accessibility: VoiceOver labels, Dynamic Type, Reduce Motion
- [ ] All text in a String Catalog
- [ ] Privacy manifest and App Store privacy answers
- [ ] Privacy policy and support pages published
- [ ] TestFlight round with 20–50 testers across time zones

**Done when:** the TestFlight build is stable and the app passes App Review.

---

## Phase order

Phases 0 and 1 come first. Phases 2–5 can then run in any order or in parallel. Phase 6 joins them. Phases 7 and 8 follow in sequence.

```
0 → 1 → ┬→ 2 ─┐
        ├→ 3 ─┤
        ├→ 4 ─┼→ 6 → 7 → 8
        └→ 5 ─┘
```

## Open questions

- [ ] Which iPhone models does iOS 27 support? Sets the quality-tier floor.
- [ ] Reserve the name Hello Sky in App Store Connect after the first real milestone.

## Decision log

| Date | Decision |
|---|---|
| 2026-10-22 | Minimum iOS raised from 18 to **27** — latest only, no back-compatibility paths, no `Material` fallback for `glassEffect` |
| 2026-10-22 | Swift 6 language mode enabled, with `MainActor` default isolation |
| 2026-10-22 | iPhone only — macOS, visionOS, tvOS, and watchOS removed from the project |
| 2026-10-22 | iPhone 12 Pro on iOS 27 confirmed as the performance baseline device |
| 2026-10-22 | Packages use swift-tools-version 6.4 — required for the `.iOS(.v27)` platform value |
| 2026-10-22 | `SkyUI` and `Globe` default to `MainActor` isolation; `SkyCore` and `SkyData` stay nonisolated |
| 2026-10-22 | Packages declare `.macOS(.v26)` alongside `.iOS(.v27)` so `swift test` runs on the host; the shipping app stays iPhone-only |
| 2026-10-22 | `Theme.name` is a `LocalizedStringResource`; the String Catalog it resolves against arrives in Phase 8 |
| 2026-10-22 | The widget keeps closure-based `TimelineProvider`; Phase 7 moves to `AppIntentTimelineProvider` for person selection |
| 2026-10-22 | The web demo is a logic and behaviour reference only — its UI is never copied; the app is designed natively against the HIG and Liquid Glass |
