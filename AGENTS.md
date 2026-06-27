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
- `EnterWorktree`工具默认基于 `origin/main` 创建 worktree，但我们需要的是 `develop` 分支。
- **进入 worktree 后，第一件事就是用 `git log --oneline -3` 检查当前 HEAD。**
  - 如果 HEAD 是 `origin/main` 的最新 commit（常见特征是 merge PR 到 main 的提交），而你需要的代码（如最近的 feature 文件）不存在，说明拉到了 `main`。此时退出 worktree 并手动通过命令行创建：
    ```
    git fetch origin develop && git worktree add --track -b <branch-name> <path> origin/develop
    ```
    然后用 `EnterWorktree` 传入 `path` 参数进入。
- 多 agent 并行时，不要删除其他 agent 创建的工作树（`.claude/worktrees/*`），即使它们看起来是孤儿或损坏的。（会话结束时的清理会处理。）

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
