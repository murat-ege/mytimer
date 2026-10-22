# MyTimer ⏱️⚡

[![Flutter](https://img.shields.io/badge/Flutter-v3.13%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**MyTimer** is an all-in-one, high-performance interval and workout timer application built with Flutter. Engineered specifically for athletes, coaches, and fitness enthusiasts, MyTimer powers **CrossFit, Hyrox, Tabata, HIIT, boxing rounds, EMOM, AMRAP, For Time, and custom routines**.

Designed with a high-contrast sports display for clear visibility across the gym, intelligent background audio mixing, an interactive iOS-style customizable dashboard, and dedicated competition modes.

---

## 🌟 Key Features

### 1. 📱 Interactive Dashboard & iOS-Style Folder System
- **Customizable Grid**: Clean, responsive timer dashboard adapting seamlessly between phone and tablet layouts.
- **Jiggle Mode**: Long-press any timer card to enter edit mode with smooth jiggle animations and haptic feedback.
- **Folder Organization**: Group workouts and timers into custom folders to keep routines organized.
- **Quick Shortcuts**: Add, reorder, or launch custom presets and standard timers directly from the home screen.

### 2. ⚡ Complete Timer Modes
- **Tabata**: Classic 20s/10s intervals or fully customized work, rest, cycles, and sets.
- **Rounds & Boxing**: Round count, round work duration, and rest interval configuration with distinct bell cues.
- **EMOM (Every Minute on the Minute)**: Clean interval counter with countdowns for each minute.
- **AMRAP (As Many Rounds As Possible)**: Target time cap with interactive round counter tap tracking.
- **For Time**: Direct stopwatch cap timer with finish recording.
- **Custom Routine Builder**: Build complex multi-phase workouts with custom step names, work/rest periods, and repeat loops.
- **Benchmark WOD Library**: Preloaded protected classic CrossFit benchmarks (*The Girls* and *Hero WODs* such as *Fran*, *Cindy*, *Murph*, *Annie*).

### 3. 🏃‍♂️ Dedicated Hyrox Training Suite
- **Hyrox Race Simulator**: Full 8-station race simulation with 1 km running splits and transition timing (SkiErg, Sled Push, Sled Pull, Burpee Broad Jumps, Rowing, Farmers Carry, Sandbag Lunges, Wall Balls).
- **Station Assessment / Tests**: Target pacing and split benchmark testing for each official Hyrox station.
- **Doubles / Relay Timer**: Tailored for partner competitions with split tracking and partner switch alerts.
- **Compromised Running**: Pre-configured running blocks paired with station fatigue movements.
- **Official Standards Reference**: In-app rulebook for division weights, distances, and category standards (Open, Pro, Doubles).

### 4. ⏱️ Precision Stopwatch & Countdown
- **Dual Mode**: High-precision millisecond count-up stopwatch and backward countdown timer.
- **Lap Tracking**: Record split times with automatic fastest and slowest lap comparisons.
- **Instant Lap Reset & Export**: Scrollable lap history with zero-lag controls.

### 5. 🔊 Audio, Voice Coach & Background Playback
- **Voice Coach (TTS)**: Spoken announcements for upcoming rounds, stations, and countdowns powered by `flutter_tts`.
- **11 Low-Latency Audio Themes**: Custom synthesized and procedural audio cue themes for start horns, countdowns, and interval transitions.
- **Background Audio Ducking**: Seamlessly mixes with background music (Spotify, Apple Music, etc.), gently ducking music volume only during audio cues.
- **Haptic Alerts**: Tactile vibration feedback for countdowns and interval transitions.
- **Background Execution**: Real-time timer synchronization on app resume and interval notifications via `flutter_local_notifications`.
- **Screen Wake Lock**: Prevents screen sleep during workouts using `wakelock_plus`.
- **Orientation Control**: Fast toggle between portrait and landscape modes for gym setups.

### 6. 📊 Workout Log & History
- **Automatic Session Logging**: Saves completed workout durations, completed rounds, and timestamps.
- **Workout Notes**: Add workout notes, reps, scaling, and athlete performance scores.
- **CSV Export & Sharing**: Export workout history in standard RFC 4180 CSV format via `share_plus`.

### 7. 🌐 Full Localization (i18n)
- Native multi-language support:
  - 🇬🇧 **English**
  - 🇹🇷 **Türkçe** (with authentic CrossFit and sports terminology)
- Real-time language switching from Settings without restarting the app.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3)
- **Architecture**: Feature-first modular structure with native ChangeNotifier controllers (`WorkoutController`, `StopwatchController`).
- **Persistence**:
  - [Hive CE](https://pub.dev/packages/hive_ce) (`hive_ce_flutter`) for fast, lightweight local NoSQL storage of custom routines, presets, and workout logs.
  - [shared_preferences](https://pub.dev/packages/shared_preferences) for user preferences and configuration.
- **Audio & Voice**:
  - [audioplayers](https://pub.dev/packages/audioplayers) for low-latency sound cues and background audio ducking.
  - [flutter_tts](https://pub.dev/packages/flutter_tts) for voice coaching announcements.
- **System Utilities**:
  - [wakelock_plus](https://pub.dev/packages/wakelock_plus) for screen wake lock.
  - [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for background timer notifications.
  - [share_plus](https://pub.dev/packages/share_plus) & [csv](https://pub.dev/packages/csv) for workout log exports.
- **UI & Styling**: Material 3 Sports Dark Theme with neon accents (`#00E676`), deep slate backgrounds (`#121212`), and [Google Fonts](https://pub.dev/packages/google_fonts).

---

## 📁 Project Structure

```text
lib/
├── controllers/          # State controllers (WorkoutController, StopwatchController)
├── data/                 # Static data sources, audio themes & default preset seeds
├── features/             # Feature-first modular screens & widgets
│   ├── home/             # Dashboard, iOS-style folder system & jiggle grid
│   ├── hyrox/            # Hyrox race, doubles, station test & standards suite
│   ├── settings/         # App preferences, audio, voice coach & language settings
│   ├── splash/           # Animated splash screen
│   ├── stopwatch/        # Precision stopwatch & countdown screen
│   ├── timer_manager/    # Preset manager, routine builder & benchmark WODs
│   ├── timer_runner/     # Fullscreen workout runner with giant typography
│   └── workout_log/      # Session history, CSV exporter & log details
├── l10n/                 # Localization ARB files & generated localizations
│   ├── app_en.arb
│   └── app_tr.arb
├── models/               # Domain models (CustomRoutine, WorkoutLog, TimerSettings, etc.)
├── repositories/         # Data access layer & Hive CE repository implementations
├── services/             # Background services (Sound, Voice Coach, Notifications, Wakelock)
├── shared/               # Shared widgets, themes, and utility helpers
└── main.dart             # Application bootstrap & localization setup
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.5` or later)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (for mobile emulators or physical devices)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/mytimer.git
   cd mytimer
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate localizations:**
   ```bash
   flutter gen-l10n
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Quality Assurance

Run all unit, widget, and layout tests:
```bash
flutter test
```

Run static code analysis:
```bash
flutter analyze
```

---

## ⚙️ Settings & Customization

Accessible via the gear icon in the top-right corner of the app:
- **Audio Themes**: Choose from 11 distinct acoustic and digital beep profiles.
- **Voice Coach**: Enable or disable spoken round announcements and countdowns.
- **Background Music Ducking**: Keep your workout playlist playing with seamless sound ducking.
- **Vibration**: Toggle haptic feedback on/off.
- **Keep Screen Awake**: Toggle display wake lock.
- **Language**: Switch dynamically between English and Türkçe.

---

## ⚖️ Trademark Disclaimer

- **CrossFit®** is a registered trademark of CrossFit, LLC.
- **HYROX®** is a registered trademark of World Series of Fitness GmbH.

**MyTimer** is an independent open-source fitness community tool. It is not affiliated with, authorized by, sponsored by, or endorsed by CrossFit, LLC, World Series of Fitness GmbH, or any of their affiliates or subsidiaries. All product and company names are trademarks™ or registered® trademarks of their respective holders; use of them does not imply any affiliation with or endorsement by them.

---

## 📄 License & Open Source

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```text
Copyright (c) 2026 Murat Ege
```

**Free & Open to All**: You are welcome to study, fork, modify, integrate, or redistribute the source code for personal or commercial purposes, provided that the original copyright notice and permission notice are preserved in all copies.
