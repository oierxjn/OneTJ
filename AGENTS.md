# AGENTS.md

## Build
- Use `fvm flutter` for all Flutter commands (pub get, run, build, test).
- On Windows, run Flutter tests via `scripts/flutter_test_no_proxy.ps1` so the
  child process can clear proxy env vars that would otherwise break local
  loopback WebSocket connections used by `flutter test`.

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
- Use Chinese in the CLI.
- When running scripts that operate on files, you may add `--Encoding utf-8` to prevent Chinese garbling.

## Git Worktrees
- The default branch for this repo is `main`; the active development branch is `develop`.
- `EnterWorktree` defaults to `origin/main` as the base ref, but work should be based on `develop`.
- **After entering a worktree, always check the current HEAD with `git log --oneline -3`.**
  - If HEAD points to the latest `origin/main` commit (typically a merge PR to main) and the code you need (e.g. recent feature files) is missing, you're on `main`. Exit the worktree and create one manually:
    ```
    git fetch origin develop && git worktree add --track -b <branch-name> <path> origin/develop
    ```
    Then enter it with `EnterWorktree` using the `path` parameter.
- When multiple agents run in parallel, do not delete worktrees created by other agents (`.claude/worktrees/*`), even if they appear orphaned or broken. Session cleanup handles them.

## Optional: Windows warnings
- To silence MSVC warning C4819 (encoding mismatch), add `/utf-8` in
  `local_packages/flutter_inappwebview/flutter_inappwebview_windows/windows/CMakeLists.txt`
  via `target_compile_options(flutter_inappwebview_windows_plugin PRIVATE /utf-8)`.

## Project structure
- `lib/app/`: app-level constants, exceptions, dependency injection, and shared presentation infrastructure.
  - `lib/app/presentation/`: shared presentation-layer types such as `BaseViewModel` and `UiEvent`.
- `lib/features/`: feature modules (e.g. `launcher`, `login`). A feature may contain `application/`, `models/`, `view_models/`, and `views/` as needed.
  - `features/<feature>/application/`: feature use cases and orchestration services. Put API calls and the coordination of repositories, caches, fallbacks, and other dependencies here.
  - `features/<feature>/models/`: feature-local data types and value objects only; it must not contain API calls, cache orchestration, `ChangeNotifier`, or UI events.
  - `features/<feature>/view_models/`: presentation-layer state holders for the feature.
  - `features/<feature>/views/`: Flutter UI for the feature.
- `lib/models/`: cross-feature data types, API response types, and value objects (including domain `*Data` classes used by repositories). Do not put `ChangeNotifier`, UI events, API calls, or cache orchestration here.
- `lib/repo/`: local/remote data access, cache, and persistence only; repositories must not own page workflows.
- `lib/services/`: shared API/services layer (e.g. `TongjiApi`, `AuthTokenProvider` for token lifecycle).
- `lib/l10n/`: localization ARB files.
- `assets/`: image assets referenced by the app.
- `local_packages/`: local forks/overrides (e.g. `flutter_inappwebview` OHOS fork).

## Feature MVVM layering
- ViewModels maintain UI state and emit `UiEvent`; they must not call APIs directly or access cache repositories directly.
- Application services own feature-level API/repository/cache/fallback orchestration and must receive dependencies through constructor injection.
- Restrict `appLocator` to `lib/app/di/` and necessary composition roots. Do not introduce `appLocator` lookups into ViewModels or application services; pass dependencies from the composition root instead.
