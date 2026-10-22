# Hello Sky

**See the sky where the people you care about are, right now.**

A world clock tells you it is 7:40 AM at Mom's. Hello Sky shows you that it is a clear, golden morning there.

Open a globe with your people on it. Tap one, and the whole screen becomes their live sky — real sun position, real clouds, real moon phase, their local time, and whether it is a good moment to call.

![Platform](https://img.shields.io/badge/platform-iOS%2027%2B-black)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![Device](https://img.shields.io/badge/device-iPhone-lightgrey)
![Status](https://img.shields.io/badge/status-Phase%200%20in%20progress-yellow)

> **Status:** early development. The project builds and runs, but no features are implemented yet.
> See [PROGRESS.md](PROGRESS.md) for the live phase-by-phase tracker.

---

## The signature moment

Tapping a person on the globe turns the screen into their live sky in about 1.5 seconds.

1. The globe rotates and zooms to their city.
2. It fades into their sky, coloured by their real sun position, clouds, and moon.
3. Their local time and a one-line status appear — *"7:40 AM, clear, good time to call."*
4. Swiping down returns to the globe.

Everything else in the app exists to support that moment.

## Features

Eight feature groups ship in v1. All of them work with no account, no server, and no network dependency beyond weather.

| | Feature | What it does | Status |
|---|---|---|---|
| 🌍 | **Globe** | Interactive 3D Earth with a live day/night line, city lights, a 24-hour time slider, and three looks | Not started |
| 👥 | **People** | Add up to 10 people with a name, city, and emoji avatar; editable awake hours; Good time / Maybe / Sleeping status; best-overlap window | Not started |
| 🌇 | **Their sky** | Live sky from sun position, clouds, and moon phase, with local time, temperature, conditions, next sun event, and a shareable sky card | Not started |
| 🌅 | **My sky** | The same screen for your own location or a typed city, with golden hour, blue hour, and moon phase | Not started |
| 📱 | **Widgets** | Small, medium, and Lock Screen widgets showing a person's time over their real sky | Not started |
| 🔔 | **Alerts** | Optional per-person sunrise and sunset notifications, computed on the device | Not started |
| 🎨 | **Looks** | Three visual themes — Realistic, Dusk, and Ink — each with its own alternate app icon | Not started |
| 🔒 | **Privacy** | No accounts, no ads, no analytics SDKs; your people list never leaves the device | By design |

### Deliberately not in v1

Accounts or any server we run · a social feed · shared people lists · photo avatars · calendar integration · Apple Watch, iPad, Mac, or Vision Pro · Android or web · ads or subscriptions · AR.

## Requirements

| | |
|---|---|
| **Xcode** | 26 or later (the project uses synchronized file groups, `objectVersion = 90`) |
| **iOS** | 27.0 minimum — latest only, by design |
| **Swift** | 6.0 language mode, with `MainActor` default isolation |
| **Devices** | iPhone only |
| **Test device** | iPhone 12 Pro on iOS 27 is the performance baseline |

A free Apple ID is enough for everything through Phase 6. The paid Apple Developer Program is needed from Phase 7 onward, for App Groups (widget data sharing), WeatherKit, and TestFlight.

## Getting started

```bash
git clone <repo-url>
cd "Hello Sky"
open "Hello Sky.xcodeproj"
```

Or from the command line:

```bash
# Build
xcodebuild -project "Hello Sky.xcodeproj" -scheme "Hello Sky" \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Test
xcodebuild -project "Hello Sky.xcodeproj" -scheme "Hello Sky" \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

No package manager step and no secrets file — the project has no third-party dependencies, and development builds use a mock weather provider by default.

> The project name contains a space, so quote every path and scheme argument.

## Architecture

The app is split into local Swift packages so each phase can be built and tested without launching the whole app.

| Module | Owns | Depends on |
|---|---|---|
| `SkyCore` | Sun and moon math, time zones, awake status, overlap windows, plain data models | Foundation only |
| `SkyData` | Weather providers, caching, SwiftData models | `SkyCore` |
| `SkyUI` | Sky renderer, `Theme`, shared SwiftUI components | `SkyCore` |
| `Globe` | RealityKit scene, shaders, textures | `SkyCore`, `SkyUI` |
| `HelloSky` | Navigation, screens, the globe-to-sky transition | all of the above |
| `HelloSkyWidgets` | Widgets and their timelines | `SkyCore`, `SkyData`, `SkyUI` |

Three rules hold the design together:

**`SkyCore` imports no UI framework.** All astronomy is pure functions taking `Date` as a parameter, so the engine tests in seconds and the sky renders reproducibly in snapshots.

**Weather passes through two seams.** `WeatherProvider` swaps the *source* — mock, Open-Meteo in development, WeatherKit at release, a shared cache later. `WeatherRepository` owns the *behaviour* — on-disk cache, in-flight request sharing, a daily call budget, and a fallback chain ending in a clear-sky model computed from astronomy. Screens only ever see `SkyWeather`, so changing weather source touches no UI.

**A look is data, not code.** `ThemeRegistry` holds sky colour keyframes, globe shader settings, accent colour, and icon name per look. Adding a look means adding one file and one icon; no screen contains look-specific code.

## Roadmap

**v1** — the eight feature groups above.
**v1.1** — sunset quality score and "was it good?" feedback.
**v2** — photo avatars, a refreshing cloud layer, daylight-saving warnings, iCloud sync, Siri and App Intents, calendar conflicts, more looks.
**v3** — sharing people lists between users.

## Privacy

Hello Sky has no accounts, no analytics SDKs, and no backend of its own. Your people list is stored on the device with SwiftData. Location is optional — My sky works from a typed city.

City coordinates are sent to Apple's weather service to retrieve forecasts. That is the only data that leaves the device, and the App Store privacy label states it.

## Credits

| Source | Credit |
|---|---|
| Apple Weather (WeatherKit) | Apple Weather mark and legal link, displayed beside the weather data |
| Open-Meteo | "Weather data by Open-Meteo.com" (development builds) |
| [Live Cloud Maps](https://github.com/matteason/live-cloud-maps) | "Contains modified EUMETSAT data" |
| NASA Blue Marble and Black Marble | Earth day and night textures |

## Documentation

| Document | What it holds |
|---|---|
| [PROGRESS.md](PROGRESS.md) | Live phase tracker — what is done, in progress, and next |
| [hello-sky-plan.md](hello-sky-plan.md) | The full product and build plan; the source of truth for scope and decisions |
| [CLAUDE.md](CLAUDE.md) | Architecture rules and coding conventions for contributors and AI assistants |
