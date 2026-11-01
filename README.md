# FitTrack

**A premium, offline-first fitness and activity tracker built with Flutter.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Storage](https://img.shields.io/badge/Storage-Hive-FFB300)

---

## About

FitTrack is a personal fitness and activity tracking app for Android. It counts your steps with the phone's built-in pedometer, logs workouts with a live calorie estimate, and turns that data into a clean daily dashboard, weekly charts, streaks and achievements.

It was built as a student project with two goals:

1. **Be genuinely useful.** Everything works offline, with no account, no sign-up and no cloud. Your data stays on your phone.
2. **Feel premium.** The interface was designed first in Google Stitch, then built to match: a dark midnight gradient, a single champagne-gold accent, heavy bold numerals and quiet, editorial typography. It avoids the neon gym-app look.

### Design language

| Element | Choice |
|---|---|
| Background | Gradient from `#07080C` to `#12142A` |
| Accent | Champagne gold `#E8C48A` to `#C98A4B`, used only for progress and key numbers |
| Surfaces | `#14172A` panels with 1px hairline borders and 24px corners |
| Headlines and numbers | Sora ExtraBold, tight tracking |
| Body text | Inter |
| Navigation | Floating pill bar with a gold active dot |

---

## Screenshots

Add your screenshots to `docs/screenshots/` and they will show here.

| Onboarding | Home | Add workout |
|---|---|---|
| ![Onboarding](docs/screenshots/onboarding.png) | ![Home](docs/screenshots/home.png) | ![Add workout](docs/screenshots/add_workout.png) |

| Workouts | Stats | Profile |
|---|---|---|
| ![Workouts](docs/screenshots/workouts.png) | ![Stats](docs/screenshots/stats.png) | ![Profile](docs/screenshots/profile.png) |

---

## Features

### Onboarding and profile
- Welcome screen followed by a short profile form: name, weight, height and daily step goal.
- Input validation with clear error messages and sensible ranges.
- Runs once and is remembered across restarts.
- Profile screen to edit name, weight, height and step goal at any time. Changes flow through to the dashboard and to calorie estimates.

### Home dashboard
- Large progress ring showing today's steps against your goal, animated on load.
- Stat tiles for calories burned, active minutes and current workout streak.
- Time-aware greeting (morning, afternoon, evening).
- Water tracker card with add and remove buttons and a progress bar toward the daily goal.
- Latest workout card that jumps to the Workouts tab.
- Friendly notice if the activity permission is denied or the device has no step sensor.

### Live step tracking
- Uses the phone's hardware step counter through the `pedometer` plugin.
- Runtime activity-recognition permission handled by a small native Kotlin channel (no extra permission plugin).
- Handles phone reboots: the sensor reports a running total, so FitTrack stores the previous reading and adds only the difference.
- Daily totals are stored per date, so history builds up automatically.

### Workout logging
- Four workout types: Run, Gym, Cycle and Yoga.
- Duration input with a large numeric display.
- Built-in workout timer with start, pause, resume, reset and a "Use time" button that fills in the duration.
- Live calorie estimate that updates as you type, based on your weight.
- Optional notes for each session.
- The timer is timestamp-based, so it stays accurate if the app is backgrounded.

### Workout history
- Sessions grouped by day with Today, Yesterday and dated headers.
- Each row shows type, duration, notes and calories.
- Swipe left to delete.
- Empty state when there are no workouts yet.

### Stats
- Seven-day bar chart with a toggle between Steps and Calories.
- Today's bar highlighted in gold, previous days in muted indigo.
- Weekly total, daily average, number of workouts and active minutes.
- Chart and totals update immediately when data changes.

### Achievements
Six badges computed from your data, so they can never fall out of sync:

| Badge | Requirement |
|---|---|
| First session | Log a workout |
| On a roll | 3-day workout streak |
| Week strong | 7-day workout streak |
| Ten sessions | Log 10 workouts |
| Century | 100 total active minutes |
| Burner | Burn 1,000 kcal in total |

### Polish
- Smooth ring animation and fade page transitions.
- Haptic feedback on bottom navigation taps.
- Consistent theme, text styles and reusable widgets across every screen.
- Everything persists between launches.

---

## Roadmap

Planned next, in rough priority order:

- [ ] Weekly insight comparing this week's steps with the previous week
- [ ] Distance and step calories derived from height and weight
- [ ] Records section: best step day, longest streak, totals
- [ ] Workout mix donut chart by type
- [ ] 28-day consistency heatmap
- [ ] Weight log with BMI and a trend line chart
- [ ] Weekly workout goal
- [ ] Repeat last workout shortcut
- [ ] Custom launcher icon and splash screen
- [ ] Local reminder notifications
- [ ] GPS route tracking for runs
- [ ] Health Connect integration
- [ ] Background step service
- [ ] Optional cloud backup and data export

---

## Tech stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Provider (`ChangeNotifier`) |
| Local database | Hive (key-value NoSQL, stored as plain maps) |
| Charts | fl_chart |
| Step sensor | pedometer |
| Typography | google_fonts (Sora and Inter) |
| Dates and number formatting | intl |
| Native bridge | Kotlin `MethodChannel` for the activity permission |

### How calories are estimated

```
calories = MET x weight (kg) x duration (hours)
```

| Activity | MET |
|---|---|
| Run | 9.8 |
| Cycle | 7.5 |
| Gym | 5.0 |
| Yoga | 2.5 |

These are estimates, not measurements.

### How the streak works

A streak is the number of consecutive days with at least one logged workout. It stays alive through the current day, so it counts back from yesterday if you have not trained yet today.

---

## Architecture

Feature-first folders with three simple layers:

```
Screen  ->  Provider  ->  Repository  ->  Hive
(UI)        (state)       (data access)    (storage)
```

- **Presentation:** screens and widgets contain UI only.
- **State:** `ChangeNotifier` providers hold app state and notify the UI.
- **Data:** models, repositories and the Hive service handle persistence.

### Folder structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/            # colors, text styles, theme
│   ├── utils/            # calorie calculator, activity permission
│   └── widgets/          # gradient background, nav bar, buttons, ring, tiles
├── data/
│   ├── models/           # Workout, UserProfile
│   ├── local/            # Hive service
│   └── repositories/     # workout and profile repositories
└── features/
    ├── onboarding/
    ├── dashboard/
    ├── workouts/         # logging, history, timer, provider
    ├── stats/
    ├── steps/            # pedometer provider
    ├── water/
    └── profile/          # profile screen, achievements
```

---

## Getting started

### Prerequisites

- Flutter SDK (stable channel)
- Android Studio with the Android SDK and Command-line Tools
- **JDK 17** for Gradle. Newer JDKs such as Java 25 are too new for the Gradle version used here.
- An Android phone with USB debugging enabled (recommended, because emulators have no step sensor)

### Run the app

```bash
git clone https://github.com/<your-username>/fittrack.git
cd fittrack
flutter pub get
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

### Permissions

| Permission | Why |
|---|---|
| `ACTIVITY_RECOGNITION` | Required by Android to read the step counter |

FitTrack needs no internet access and collects no data.

### Troubleshooting

| Problem | Fix |
|---|---|
| Gradle fails with a bare version number such as `25.0.2` | Gradle is running on a JDK that is too new. Point Flutter at JDK 17 with `flutter config --jdk-dir="<path-to-jdk-17>"`. |
| `cmdline-tools component is missing` | Install Android SDK Command-line Tools in the SDK Manager, then run `flutter doctor --android-licenses`. |
| Steps stay at 0 | Emulators have no step sensor. Test on a physical phone and allow the Physical activity permission. |
| Permission prompt never appears | Fully stop and rebuild the app after native (Kotlin) changes. A hot restart is not enough. |

---

## Known limitations

- Steps are counted only while the app process is alive (no background service yet).
- Calories and step-derived values are estimates.
- Data is stored locally only, with no sync between devices.
- Android only.

---

## Author

Built by **Piyush Gupta** as a student project.

## License

Add a license of your choice, for example MIT, before making the repository public.