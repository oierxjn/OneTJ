<div align="center">

[![OneTJ Logo](assets/icon/logo.jpg)](https://github.com/oierxjn/OneTJ)
# OneTJ

[中文](README_zh.md) | [English](README.md)

OneTJ is a third-party client for Tongji University services built with Flutter.
The project focuses on a cleaner student experience around authentication,
dashboard data, timetable viewing, grades, and utility tools.

Original repository: [FlowerBlackG/OneTJ](https://github.com/FlowerBlackG/OneTJ)

</div>

## Status

This project is under active development. Some features are complete enough for
daily use, while others are still evolving.

Current app version: `2.4.1+13`

## Features

- WebView-based login flow for Tongji authentication
- Dashboard with student profile and current term calendar
- Timetable view
- Grades module
- Tools entry, including physics lab related pages
- Settings, about page, developer options, and log viewer
- Local persistence with Hive and shared preferences
- Chinese and English localization

## Tech Stack

- Flutter / Dart
- Material 3
- `go_router`
- Hive
- `flutter_inappwebview`

## Platform And Dependency Notes

- Use `fvm flutter` for all Flutter commands in this repository.
- The project depends on a local OpenHarmony fork of
  `flutter_inappwebview` under
  `local_packages/flutter_inappwebview`.
- `pubspec.yaml` pins the `flutter_inappwebview_*` subpackages through
  `dependency_overrides`.
- HarmonyOS-related dependencies such as `path_provider`,
  `device_info_plus`, `image_picker`, `open_filex`, and
  `flutter_math_fork` are sourced from OpenHarmony-compatible forks.

## Quick Start

1. Ensure FVM is installed and the required Flutter SDK is available.
2. Make sure `local_packages/flutter_inappwebview` exists in the workspace.
3. Install dependencies:

```bash
fvm flutter pub get
```

4. If model serialization files need regeneration, run:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

5. Run the app:

```bash
fvm flutter run
```

## Project Structure

- `lib/app/`: app bootstrap, dependency injection, constants, lifecycle, router
- `lib/features/`: feature modules such as launcher, login, dashboard,
  timetable, grades, tools, settings, about, and app update
- `lib/models/`: shared models and generated serialization targets
- `lib/repo/`: repositories for cached and persisted data
- `lib/services/`: API integration and app services
- `lib/l10n/`: localization resources
- `assets/`: app assets
- `local_packages/`: local plugin forks and overrides
- `docs/`: supplementary project documentation

## App Flow

1. App startup initializes dependencies and lifecycle services.
2. Launcher checks locally cached authentication state.
3. If login is required, the app opens a WebView-based authentication flow.
4. After login, the app enters the home shell with dashboard, timetable,
   tools, and settings tabs.
5. Feature modules fetch and cache student-related data as needed.

## Development Notes

- Do not edit generated files under `windows/flutter/ephemeral/`.
- Do not manually edit `*.g.dart` files; regenerate them with `build_runner`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for additional collaboration guidance.

![Repo Status](https://raw.githubusercontent.com/oierxjn/OneTJ/refs/heads/metrics-renders/metrics.svg)

![Code Churn](https://raw.githubusercontent.com/oierxjn/OneTJ/refs/heads/metrics-renders/daily-churn.svg)
