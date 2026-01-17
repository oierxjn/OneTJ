# AGENTS.md

## Build
- Use `fvm flutter` for all Flutter commands (pub get, run, build, test).

## Dependencies
- HarmonyOS WebView package comes from the OpenHarmony fork of `flutter_inappwebview`
  (branch `br_v6.1.5_ohos`) cloned into `local_packages/flutter_inappwebview`.
- The app pins all `flutter_inappwebview_*` subpackages to that local clone via
  `dependency_overrides` in `pubspec.yaml`.

## Workflow
- Do not edit generated files under `windows/flutter/ephemeral/`.

## Optional: Windows warnings
- To silence MSVC warning C4819 (encoding mismatch), add `/utf-8` in
  `local_packages/flutter_inappwebview/flutter_inappwebview_windows/windows/CMakeLists.txt`
  via `target_compile_options(flutter_inappwebview_windows_plugin PRIVATE /utf-8)`.
