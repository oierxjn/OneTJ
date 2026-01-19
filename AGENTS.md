# AGENTS.md

## Build
- Use `fvm flutter` for all Flutter commands (pub get, run, build, test).

## Dependencies
- HarmonyOS WebView package comes from the OpenHarmony fork of `flutter_inappwebview`
  (branch `br_v6.1.5_ohos`) cloned into `local_packages/flutter_inappwebview`.
- The app pins all `flutter_inappwebview_*` subpackages to that local clone via
  `dependency_overrides` in `pubspec.yaml`.
- For HarmonyOS, `path_provider` must be overridden to the OpenHarmony git source to
  avoid hosted-vs-git resolver conflicts (needed by `hive_flutter`).

## Workflow
- Do not edit generated files under `windows/flutter/ephemeral/`.
- Do not modify Chinese text because of perceived garbling; treat it as an encoding artifact.
- Do not manually edit or create `*.g.dart` files; use `build_runner` instead.

## Optional: Windows warnings
- To silence MSVC warning C4819 (encoding mismatch), add `/utf-8` in
  `local_packages/flutter_inappwebview/flutter_inappwebview_windows/windows/CMakeLists.txt`
  via `target_compile_options(flutter_inappwebview_windows_plugin PRIVATE /utf-8)`.

## Project structure
- `lib/app/`: app-level constants and exceptions.
- `lib/features/`: feature modules (e.g. `launcher`, `login`) with `models/`, `view_models/`, `views/`.
- `lib/models/`: shared data models (including API response models).
- `lib/repo/`: repositories for persistence/cache (e.g. token repo).
- `lib/services/`: API/services layer (e.g. `TongjiApi`).
- `lib/l10n/`: localization ARB files.
- `assets/`: image assets referenced by the app.
- `local_packages/`: local forks/overrides (e.g. `flutter_inappwebview` OHOS fork).
