# MyTimer ⏱️⚡

[![Flutter](https://img.shields.io/badge/Flutter-v3.13%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

**MyTimer** is a modern, high-performance interval and workout timer application built with Flutter. Specifically engineered for athletes, coaches, and fitness enthusiasts, it supports **CrossFit, Tabata, HIIT, circuit training, boxing rounds, and custom routines**.

---

## 🌟 Key Features

### 1. ⚡ Tabata Timer
- Quick-start classic Tabata interval setup (e.g., 20s Work / 10s Rest).
- Configurable preparation time, work duration, rest interval, and number of sets/cycles.
- Real-time visual progress indicators with bold color states.

### 2. 🥊 Rounds / Interval Timer
- Tailored for martial arts, boxing, circuit training, and HIIT sessions.
- Easily configure round count, round work time, and rest intervals.
- Distinct audio cues and high-visibility countdowns between rounds.

### 3. ⏱️ Precision Stopwatch
- Millisecond-accurate digital stopwatch.
- Lap and split time recording with lap comparison (fastest/slowest lap tracking).
- Clean, scrollable lap list with instant reset and pause capabilities.

### 4. 📋 Custom Routines & Benchmark WODs
- **Routine Builder**: Create complex multi-phase workouts with customized step names, work/rest periods, and repeat loops.
- **Pre-seeded Benchmark WODs**: Comes with classic CrossFit benchmarks (e.g., *Fran*, *Cindy*, *Murph*, *Annie*) pre-configured out-of-the-box.
- Search, filter by category (*The Girls*, *Hero WODs*, *Custom*), duplicate, and edit workouts.

### 5. 🏃 Immersive Workout Runner
- **High-Contrast Display**: Giant, glanceable typography optimized for viewing from across the gym or training ground.
- **Sound & Audio Cues**: Distinct beeps, 3-2-1 countdown signals, and completion horns powered by `audioplayers`.
- **Haptic Feedback**: Tactile vibration alerts for interval transitions.
- **Screen Wake Lock**: Prevents phone display from sleeping mid-workout (`wakelock_plus`).
- **Background Support & Notifications**: Keeps timing accurately with local notifications when the app is minimized (`flutter_local_notifications`).

### 6. 🌐 Localization (i18n)
- Native multi-language support:
  - 🇬🇧 English
  - 🇹🇷 Turkish (Türkçe)
- Dynamic runtime language switching from the settings screen without restarting the app.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3)
- **State Management & Controllers**: Native ChangeNotifier architecture (`WorkoutController`, `StopwatchController`) for clean separation of concerns and high frame rates.
- **Local Storage**: [Hive CE](https://pub.dev/packages/hive_ce) (`hive_ce_flutter`) for fast, lightweight NoSQL persistence of routines and workouts; [shared_preferences](https://pub.dev/packages/shared_preferences) for application settings.
- **Audio & Haptics**: [audioplayers](https://pub.dev/packages/audioplayers) for low-latency sound playback.
- **Device Utilities**: [wakelock_plus](https://pub.dev/packages/wakelock_plus) for display management; [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for interval alerts.
- **Design & UI**: Material 3 Dark Sports theme (custom neon accents `#00E676`, deep charcoal backgrounds `#121212`).

---

## 📁 Project Structure

```text
lib/
├── controllers/          # State controllers (WorkoutController, StopwatchController)
├── data/                 # Data sources & default presets
├── l10n/                 # Localization files (.arb) & generated localizations
│   ├── app_en.arb
│   └── app_tr.arb
├── features/             # Feature-first modules (home, tabata, rounds, emom, hyrox, etc.)
├── models/               # Domain models (CustomRoutine, IntervalStep, TimerSettings, WorkoutLog)
├── repositories/         # Data repositories & Hive CE storage layer
├── services/             # Core system services (Sound, Notification, Wakelock, VoiceCoach)
├── shared/               # Shared reusable widgets (banners, sheets, steppers, buttons)
└── main.dart             # Application entry point & theme configuration
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.5` or later)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (for mobile emulators or devices)

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

3. **Generate localizations (if required):**
   ```bash
   flutter gen-l10n
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

### Running Tests

Execute unit and widget tests:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```

### Building for Android (Release)

For release builds with app signing, copy the example key properties:
```bash
cp android/key.properties.example android/key.properties
# Edit android/key.properties with your keystore credentials
flutter build apk --release
```

---

## ⚙️ Configuration & Settings

From the in-app **Settings** screen (accessible via the gear icon in the top-right corner):
- **Sound Effects**: Toggle sound cues on/off.
- **Vibration**: Toggle haptic feedback on/off.
- **Keep Screen Awake**: Toggle display wake lock.
- **Language**: Switch between English and Türkçe instantly.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
