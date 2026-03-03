# CI Environment Setup

This project provides cross-platform CI scripts under `scripts/`:

- `bootstrap_ci_env.ps1|cmd|sh`: install/check `fvm`, install/check OHOS Flutter SDK, set `.fvmrc`, and sync `ohos/local.properties`.
- `check_ci.ps1|cmd|sh`: run CI checks with `fvm flutter pub get`, `fvm flutter analyze`, and `fvm flutter test --no-pub`.

## Environment variables

- `FVM_FLUTTER_VERSION`: FVM version name. Default: `ohos_flutter`.
- `OHOS_FLUTTER_SDK`: absolute path to OHOS Flutter SDK.  
  Default: `${FVM_VERSIONS_DIR}/${FVM_FLUTTER_VERSION}` or `${FVM_CACHE_PATH}/versions/${FVM_FLUTTER_VERSION}`.
- `OHOS_FLUTTER_GIT_URL`: git URL to clone OHOS Flutter SDK when missing.  
  Default: `https://gitcode.com/openharmony-tpc/flutter_flutter.git`
- `OHOS_FLUTTER_GIT_REF`: git ref/branch for OHOS Flutter SDK clone.  
  Default: `oh-3.27.4-dev`
- `FVM_CACHE_PATH`: optional FVM cache root.
- `FVM_VERSIONS_DIR`: optional explicit FVM versions directory.

## Usage

Windows PowerShell:

```powershell
.\scripts\bootstrap_ci_env.ps1
.\scripts\check_ci.ps1
```

Windows CMD:

```cmd
scripts\bootstrap_ci_env.cmd
scripts\check_ci.cmd
```

Linux:

```bash
sh scripts/bootstrap_ci_env.sh
sh scripts/check_ci.sh
```

Optional flags:

- PowerShell: `.\scripts\check_ci.ps1 -SkipBootstrap -SkipTests`
- Linux: `SKIP_BOOTSTRAP=1 SKIP_TESTS=1 sh scripts/check_ci.sh`
