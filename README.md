# Cute Pomo

A beautifully designed Pomodoro timer built with Flutter, featuring a unique gamification twist: unlock real campus photos of India's top engineering colleges as you study.

## Features

### Pomodoro Timer
- Configurable work, short break, and long break durations
- Animated progress ring with smooth countdown display
- Play/pause, reset, and +10 minute controls
- Auto-start next phase option
- Alarm sound on phase completion
- Session tracking within Pomodoro cycles (e.g., "Session 2 of 4")

### Campus Gallery (Gamification)
- **20 colleges** ranked from NIT Durgapur (easiest) to IIT Bombay (hardest)
- Complete Pomodoro sessions to unlock campus photo galleries
- **Progressive photo unlocking** — photos within each college unlock one at a time, not all at once
- Each subsequent photo requires ~10% more sessions than the college's base threshold
- Gallery shows unlock progress: "X/Y photos" on each college card
- Progress bar tracks your journey to the next unlock
- Celebratory dialog when a new campus is unlocked

### Customization
- Light, dark, and system theme modes (cream/pink light, indigo/pink dark)
- Adjustable work duration (1-60 min)
- Adjustable break durations (short: 1-30 min, long: 1-60 min)
- Configurable sessions before long break (1-8)
- Sound toggle

### Stats & Tracking
- Today's session count
- Total sessions (accounts for bonus time from +10 min)
- Current streak (consecutive days)
- All stats persisted locally via SharedPreferences

## Architecture

```
lib/
  main.dart             # App entry, themes, routing
  timer_page.dart       # Timer UI, animations, Pomodoro cycle logic
  models.dart           # TimerPhase enum, TimerConfig, SessionRecord
  storage_service.dart  # SharedPreferences wrapper for settings & stats
  settings_sheet.dart   # Bottom sheet for configuring durations
  college_data.dart     # College definitions, unlock thresholds, photo progression
  campus_viewer.dart    # Full-screen photo viewer with page indicators
  gallery_screen.dart   # College grid with stats, progress bars, photo counts
```

## How Unlocking Works

| College | Unlock At | Photos | Photo Thresholds |
|---------|-----------|--------|-----------------|
| NIT Durgapur | 2 sessions | 5 | 2, 3, 4, 5, 6 |
| NIT Nagpur | 5 sessions | 5 | 5, 6, 7, 8, 9 |
| NIT Warangal | 30 sessions | 5 | 30, 33, 36, 39, 42 |
| IIT Bombay | 260 sessions | 4 | 260, 286, 312, 338 |

Bonus time from the +10 minute button counts toward session totals: every 25 cumulative focus minutes equals one session for unlock calculations.

## Getting Started

### Prerequisites
- Flutter SDK ^3.7.2
- Dart 3.7+

### Setup

```bash
git clone https://github.com/Stealthinator16/pomodoro_timer.git
cd pomodoro_timer
flutter pub get
flutter run
```

## Dependencies

- **audioplayers** — alarm sound playback
- **shared_preferences** — local persistence for settings and session history
- **cached_network_image** — efficient loading and caching of campus photos
- **flutter_native_splash** — branded splash screen
- **flutter_launcher_icons** — custom app icons across platforms

## Platforms

Built with Flutter for cross-platform support:
- Android
- iOS
- macOS
- Web
- Windows
- Linux
