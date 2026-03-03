#!/usr/bin/env sh
set -eu

if command -v fvm >/dev/null 2>&1; then
  fvm dart scripts/update_app_version.dart "$@"
  exit $?
fi

if command -v dart >/dev/null 2>&1; then
  dart scripts/update_app_version.dart "$@"
  exit $?
fi

echo "Neither 'fvm' nor 'dart' was found in PATH." >&2
exit 1
