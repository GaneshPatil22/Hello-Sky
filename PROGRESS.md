# Progress

Live tracker for Hello Sky. Updated before every commit.

**Current phase:** Phase 7 — Widgets and alerts
**Last updated:** 2026-10-23
**Overall:** 7 of 9 phases complete · roughly 252 of 248–332 hours

```
Phase 0  ██████████  complete
Phase 1  ██████████  complete
Phase 2  ██████████  complete
Phase 3  ██████████  complete
Phase 4  ██████████  complete
Phase 5  ██████████  complete
Phase 6  ██████████  complete
Phase 7  ░░░░░░░░░░  not started
Phase 8  ░░░░░░░░░░  not started
```

---

## Right now

**Working on:** nothing. Phases 0 to 6 are done and checked on the device. The sky screen now carries the sun's arc, the shared waking hours, and a sunrise or sunset reminder. 244 tests, 34 of them in the app itself.

**Next three things:**
1. Enrol in the Apple Developer Program, which is what Phase 7 waits on.
2. Then Phase 7: the App Group store, the WidgetKit timelines, and the sunrise and sunset notifications.
3. Decide the two open questions below; neither blocks Phase 7.

**Open questions:**
- The title says **Hello Sky**, not "Same Sky" as the reference screenshots do. Same Sky was the prototype's name; the product name was settled as Hello Sky in section 0 of the plan. Say which should win.
- The reference tab bar reads Globe / My sky / **Widgets**. Ours keeps **People**, because widgets do not exist until Phase 7 and a tab leading to nothing is worse than one that works. The bar's styling now matches the reference either way.

**Blocked on:** Phase 7 onward needs the paid Apple Developer Program, for App Groups, WeatherKit and TestFlight. Nothing before that is blocked.

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
- [x] Verify: app installs on the iPhone 12 Pro with a free Apple ID

**Done when:** a fresh clone builds and passes all tests with one command, and a test look added only through the registry appears in the look picker.

## Phase 1 — Sky engine

*Target 20–28 h · all astronomy and time logic proven by unit tests before any screen exists.*

- [x] Sun elevation, azimuth, and subsolar point
- [x] Sunrise and sunset search, including polar day and night
- [x] Moon phase and rough moon position
- [x] Local-time helpers built on `TimeZone`
- [x] Awake-status rules
- [x] Best-overlap window finder
- [x] Fixtures generated from `astral`, two-minute tolerance
- [x] Edge-case tests: half-hour and 45-minute zones, date line, DST, polar day/night, leap day
- [x] Performance check: next-event search fast enough to call every second
- [x] `make check-core` enforces that `SkyCore` imports no UI framework

**Done when:** all tests pass and the package imports no UI framework.

## Phase 2 — People and storage

*Target 20–28 h · add, edit, and remove people with correct local time and call status.*

- [x] SwiftData model for a person, with a versioned schema and migration plan
- [x] City search with MapKit local search, falling back to the catalogue
- [x] Bundled list of 201 cities for offline use and tests
- [x] Debug seeding from mock fixtures
- [x] Status and overlap computed by `SkyCore`
- [x] A plain list screen showing local time and call status
- [x] Tests: model mapping, lightweight schema migration, in-memory store, relaunch persistence
- [x] Adding Tokyo is covered: at the store (`tokyoReadsCorrectly`) and through the add-person model, in the app's own test target

**Done when:** people survive a relaunch and the list shows correct times for every test city.

## Phase 3 — Weather layer

*Target 20–28 h · any screen can ask for a place's weather and always get an answer.*

- [x] `SkyWeather` model and `WeatherProvider` protocol
- [x] `MockWeatherProvider` reading fixtures
- [x] `OpenMeteoProvider` with its credit line, decoding saved responses in tests
- [x] `WeatherRepository`: cache, request sharing, daily budget, clear-sky fallback
- [x] On-disk cache keyed by city and hour, surviving relaunch
- [x] Provider choice by build configuration
- [x] Contract tests running the same assertions on every provider
- [x] Stub `SharedCacheProvider` proving a new source needs no screen changes
- [x] Debug screen listing weather for every person

**Done when:** with the network off, every person still shows a weather value, and switching providers needs no screen changes.

## Phase 4 — Sky renderer

*Target 35–45 h · a sky that is a pure function of place, time, weather, and look.*

- [x] `SkyView` with `TimelineView` and `Canvas`
- [x] Stars, clouds, moon with real phase, hills, rain
- [x] `MeshGradient` atmosphere, with a radial sun glow placed by real azimuth
- [x] Seeded randomness so previews and snapshots stay stable
- [x] Debug gallery: times × weather × looks, plus a time-slider screen
- [x] Snapshot tests for 12 fixed cases, rendered with `ImageRenderer`
- [x] Still-frame path for Reduce Motion
- [x] Frame-time profiling on the iPhone 12 Pro
- [x] The three looks checked by eye on the device

**Done when:** the gallery looks right for four cities at six times of day, and the time slider changes the sky smoothly.

## Phase 5 — Globe

*Target 46–63 h · the realistic globe, working on its own before it joins the app.*

- [x] **Spike:** RealityKit custom material with a Metal surface shader, running on iOS
- [x] Continents from a 32 KB Natural Earth land mask — no imagery, NASA textures dropped
- [x] Day/night shading driven by `SkyCore` sun direction, with city lights at night
- [x] Atmosphere glow and a latitude and longitude graticule
- [x] Orbit dragging with inertia and slow auto-rotation (`GlobeCamera`)
- [x] 3D→screen projection with back-face culling and edge fading
- [x] People markers drawn as avatar bubbles, tappable, with status and labels
- [x] Great-circle arc maths
- [x] Arcs drawn between people
- [x] Three looks as globe palettes — written, but only Realistic has been seen
- [x] Automatic quality tiers with a manual override (`GlobeQualityGovernor`)
- [x] Tests: sun direction matches `SkyCore`, day/night line at zero elevation, solstice and equinox checks, texture memory

**Done when:** a test slider moves the day/night line correctly and the globe stays smooth while dragging on the iPhone 12 Pro.

## Phase 6 — App flow and the signature transition

*Target 44–56 h · the whole flow running on the real engine.*

- [x] Navigation state machine (`SkyTransition`), refusing a second tap mid-move
- [x] The zoom-and-reveal transition (camera turn plus circular mask), with a Reduce Motion crossfade
- [x] One shared time model with offset
- [x] Their sky and My sky screens
- [x] Add-person, Look and Settings sheets
- [x] A home person, which every arc starts from
- [x] Tests: the transition state machine, and the reveal geometry
- [x] Share card through `ImageRenderer`, rendered only when shared
- [x] About and credits screen, reading its weather credit from the provider
- [x] An app test target, covering the clock, the settings, adding a person and the card
- [x] The sky screen: sun arc, overlap bars, weather chips, and a sunrise or sunset reminder

**Done when:** every flow works with real astronomy, mock weather, and the real globe.

## Phase 7 — Widgets and alerts

*Target 25–32 h · widgets and notifications from the same data as the app.*

- [ ] **Before starting:** enrol in the Apple Developer Program
- [ ] Shared store in an App Group container
- [ ] WidgetKit timeline provider built from `SkyCore`
- [ ] Small, medium, and Lock Screen widgets
- [~] Local notifications for sunrise and sunset — one can be set by hand from a sky; the scheduled rolling window is still Phase 7
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
| 2026-10-23 | The night region is derived as `a < −sz·√(1−b²)` in sun-aligned screen coordinates and checked pixel by pixel against the real light, after a hand-built ellipse put the shadow over the wrong countries |
| 2026-10-23 | The sun and moon are placed across the sky by **hour angle**, not azimuth. Near the equator the azimuth barely moves all morning and then swings through half a turn within minutes of noon, so a sun placed by it climbs and falls in a straight line |
| 2026-10-23 | The sky screen's accent is derived from the horizon colour rather than fixed per look, so the slider, the arc and the share button drift with the sky instead of switching between two states |
| 2026-10-23 | The header sits outside the scroll view: a back button that scrolls off the top cannot be tapped |
| 2026-10-23 | The sky fades into the page rather than ending on a line, so the screen reads as one surface instead of a picture with a page under it |
| 2026-10-23 | The sun is drawn as a disc with a corona, not only as a wash: a sunrise with no visible sun reads as coloured fog |
| 2026-10-23 | The time slider moved into the scrolling content, between the overlap card and the actions, in a compact row |
| 2026-10-23 | Sunrise and sunset reminders are local notifications, which need no paid account, so one can be set by hand from a sky before Phase 7 builds the rolling schedule |
| 2026-10-23 | At night the sun waits at the start of its arc when a sunrise is next, so the card reads as the day ahead rather than one just finished |
| 2026-10-23 | The share card is a `Transferable` rather than an `Image`, so the render happens when someone shares rather than on every frame of a screen that redraws constantly |
| 2026-10-23 | The credits screen reads its weather credit from the provider, so changing source changes the credit and the app cannot credit a service it no longer uses |
| 2026-10-23 | NASA and EUMETSAT credits are out of the plan along with the imagery; Natural Earth is in |
| 2026-10-23 | Returning the clock to now is stepped by hand over 0.85s. The globe is drawn in a `Canvas`, so SwiftUI cannot interpolate the date for us and an animation around the assignment still arrives in one jump |
| 2026-10-23 | The globe's drift is a closed-form function of time, not state stepped each frame. Writing the camera sixty times a second re-laid out every marker and made the motion stutter |
| 2026-10-23 | One timeline drives the Earth, the arcs and the markers together; the pulsing rings read that clock instead of running one each |
| 2026-10-23 | The tab bar is drawn by hand. The system bar on this release is a floating capsule with a selected pill, which no styling turns into the flat bar the design calls for |
| 2026-10-23 | The arc colour is a look value (`arcTint`), warm gold rather than the blue accent, and the travelling lights share the city lights' drawing so the globe has one idea of what a light is |
| 2026-10-23 | Arcs carry no status. The lines say who you follow; the rings around the avatars say how they are. Mixing them would make the globe a chart of statuses |
| 2026-10-23 | One dot per arc at constant angular speed, so longer arcs take longer and the dots drift out of step by themselves |
| 2026-10-23 | A home person is chosen in settings; every arc starts there and the time card reads that city's clock |
| 2026-10-22 | **NASA textures dropped.** The globe draws continents from a 32 KB Natural Earth land mask and a scatter of dots, as the prototype does. No imagery, no attribution burden, and all three looks restyle it |
| 2026-10-22 | The globe moved from RealityKit to a SwiftUI `Canvas`. RealityKit was chosen for a photographic Earth; without textures a drawn globe is simpler and matches the reference. The shader spike is in git history if imagery ever returns |
| 2026-10-22 | Globe lighting is computed in the Earth's own frame, not the view's, so turning the globe no longer changes what time it is anywhere |
| 2026-10-22 | The transition is a state machine, so a second tap during a move is refused rather than leaving the globe turning towards one city while another's sky opens |
| 2026-10-22 | Markers fade against the reveal rather than switching off when the move starts, which had left the globe bare for half a second |
| 2026-10-22 | **Design direction changed:** the web demo's layout and density are now the reference, executed with Liquid Glass and native type rather than its stylesheet. Replaces the earlier rule that the app should never resemble the demo |
| 2026-10-22 | The globe shader sets emissive as well as base colour: the scene carries no lights, so a lit-only colour rendered black |
| 2026-10-22 | The render test suite is serialized; `ImageRenderer` returns nil under parallel contention, which looked like nondeterminism and was not |
| 2026-10-22 | **Spike result:** RealityKit custom materials work on iOS, and SwiftPM compiles `.metal` files inside a package. The globe is RealityKit; the Metal-view fallback is not needed |
| 2026-10-22 | People markers are SwiftUI overlays projected onto the scene, not 3D entities, so taps, labels and VoiceOver stay ordinary |
| 2026-10-22 | The quality governor needs four times as much evidence to raise a tier as to drop one, so it cannot flicker |
| 2026-10-22 | The weather *model* moved to `SkyCore`; providers and the repository stayed in `SkyData`, so `SkyUI` can render weather without depending on where it comes from |
| 2026-10-22 | Seeded art uses a launch-stable FNV-1a hash, not Swift's per-process `hashValue`, so a city's stars never move between runs |
| 2026-10-22 | Rendering is tested for determinism and distinctness rather than against golden images, which would churn while the looks are still placeholders |
| 2026-10-22 | `SkyWeather` carries a `WeatherOrigin`, so an estimate is never shown under a weather service's attribution |
| 2026-10-22 | An estimated reading reports no temperature rather than inventing one |
| 2026-10-22 | The repository cannot fail: live, then cache however stale, then a clear sky — so no screen needs a weather error path |
| 2026-10-22 | `StoredPerson` has defaults on every property and no unique attributes, so v2's iCloud sync needs no migration |
| 2026-10-22 | The avatar is stored as kind plus value, so photo avatars in v2 add a kind rather than change the schema |
| 2026-10-22 | A row that cannot be read — unknown avatar kind or time zone — is skipped, not deleted; a later version may understand it |
| 2026-10-22 | Sunrise and sunset are found by a 5-minute scan plus 14 bisections, matching `astral` to within 67 seconds |
| 2026-10-22 | Polar day and night are reported as an absence of events, so callers cannot assume a sunrise is coming |
| 2026-10-22 | Packages declare `.macOS(.v26)` alongside `.iOS(.v27)` so `swift test` runs on the host; the shipping app stays iPhone-only |
| 2026-10-22 | `Theme.name` is a `LocalizedStringResource`; the String Catalog it resolves against arrives in Phase 8 |
| 2026-10-22 | The widget keeps closure-based `TimelineProvider`; Phase 7 moves to `AppIntentTimelineProvider` for person selection |
| 2026-10-22 | The web demo is a logic and behaviour reference only — its UI is never copied; the app is designed natively against the HIG and Liquid Glass |
