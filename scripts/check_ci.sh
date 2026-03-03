#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

SKIP_BOOTSTRAP="${SKIP_BOOTSTRAP:-0}"
SKIP_TESTS="${SKIP_TESTS:-0}"
if [ "$SKIP_BOOTSTRAP" != "1" ]; then
  sh "$SCRIPT_DIR/bootstrap_ci_env.sh"
fi

cd "$REPO_ROOT"
fvm flutter pub get
fvm flutter analyze lib test
if [ "$SKIP_TESTS" != "1" ]; then
  fvm flutter test --no-pub test
fi
