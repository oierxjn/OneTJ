#!/usr/bin/env sh
set -eu

log() {
  echo "[bootstrap_ci_env] $*"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

FVM_FLUTTER_VERSION="${FVM_FLUTTER_VERSION:-ohos_flutter}"
OHOS_FLUTTER_GIT_URL="${OHOS_FLUTTER_GIT_URL:-https://gitcode.com/openharmony-tpc/flutter_flutter.git}"
OHOS_FLUTTER_GIT_REF="${OHOS_FLUTTER_GIT_REF:-oh-3.27.4-dev}"

if [ -n "${FVM_VERSIONS_DIR:-}" ]; then
  VERSIONS_DIR="$FVM_VERSIONS_DIR"
elif [ -n "${FVM_CACHE_PATH:-}" ]; then
  VERSIONS_DIR="$FVM_CACHE_PATH/versions"
else
  VERSIONS_DIR="$HOME/fvm/versions"
fi

OHOS_FLUTTER_SDK="${OHOS_FLUTTER_SDK:-$VERSIONS_DIR/$FVM_FLUTTER_VERSION}"
FVMRC_PATH="$REPO_ROOT/.fvmrc"
LOCAL_PROPERTIES_PATH="$REPO_ROOT/ohos/local.properties"

ensure_ohos_flutter_sdk() {
  if [ -x "$OHOS_FLUTTER_SDK/bin/flutter" ]; then
    log "OHOS Flutter SDK found: $OHOS_FLUTTER_SDK"
    return
  fi

  if [ -e "$OHOS_FLUTTER_SDK" ]; then
    echo "Path exists but is not a valid Flutter SDK: $OHOS_FLUTTER_SDK" >&2
    exit 1
  fi
  if ! command_exists git; then
    echo "git is required to clone OHOS Flutter SDK." >&2
    exit 1
  fi
  log "Cloning OHOS Flutter SDK from $OHOS_FLUTTER_GIT_URL ($OHOS_FLUTTER_GIT_REF)."
  mkdir -p "$(dirname "$OHOS_FLUTTER_SDK")"
  if [ -n "$OHOS_FLUTTER_GIT_REF" ]; then
    git clone --branch "$OHOS_FLUTTER_GIT_REF" "$OHOS_FLUTTER_GIT_URL" "$OHOS_FLUTTER_SDK"
  else
    git clone "$OHOS_FLUTTER_GIT_URL" "$OHOS_FLUTTER_SDK"
  fi
}

ensure_fvm() {
  if command_exists fvm; then
    return
  fi

  log "fvm not found. Installing via dart pub global activate fvm."
  if command_exists dart; then
    dart pub global activate fvm
  else
    log "System dart not found. Bootstrapping OHOS Flutter SDK to use bundled dart."
    ensure_ohos_flutter_sdk
    if [ ! -x "$OHOS_FLUTTER_SDK/bin/dart" ]; then
      echo "No system dart and no bundled dart at $OHOS_FLUTTER_SDK/bin/dart" >&2
      exit 1
    fi
    export PATH="$OHOS_FLUTTER_SDK/bin:$PATH"
    "$OHOS_FLUTTER_SDK/bin/dart" pub global activate fvm
  fi

  export PATH="$HOME/.pub-cache/bin:$PATH"
  if ! command_exists fvm; then
    echo "fvm not found in PATH after installation." >&2
    exit 1
  fi
}

ensure_fvm
ensure_ohos_flutter_sdk

printf '{\n  "flutter": "%s"\n}\n' "$FVM_FLUTTER_VERSION" > "$FVMRC_PATH"
log "Updated .fvmrc -> $FVM_FLUTTER_VERSION"

(cd "$REPO_ROOT" && fvm use "$FVM_FLUTTER_VERSION" --force --skip-pub-get)
log "Project is configured to use '$FVM_FLUTTER_VERSION'."

escaped_sdk=$(printf '%s' "$OHOS_FLUTTER_SDK" | sed 's|\\|\\\\|g')
sdk_line="flutter.sdk=$escaped_sdk"

if [ -f "$LOCAL_PROPERTIES_PATH" ]; then
  if grep -q '^flutter\.sdk=' "$LOCAL_PROPERTIES_PATH"; then
    awk -v line="$sdk_line" '
      BEGIN { updated = 0 }
      /^flutter\.sdk=/ { print line; updated = 1; next }
      { print }
      END { if (updated == 0) print line }
    ' "$LOCAL_PROPERTIES_PATH" > "$LOCAL_PROPERTIES_PATH.tmp"
    mv "$LOCAL_PROPERTIES_PATH.tmp" "$LOCAL_PROPERTIES_PATH"
  else
    printf '\n%s\n' "$sdk_line" >> "$LOCAL_PROPERTIES_PATH"
  fi
else
  printf '%s\n' "$sdk_line" > "$LOCAL_PROPERTIES_PATH"
fi
log "Updated ohos/local.properties flutter.sdk."

(cd "$REPO_ROOT" && fvm flutter --version)
log "Environment bootstrap completed."
