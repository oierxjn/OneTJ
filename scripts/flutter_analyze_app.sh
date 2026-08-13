#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
strict=false
analyze_args=()

for arg in "$@"; do
  case "$arg" in
    --strict)
      strict=true
      ;;
    *)
      analyze_args+=("$arg")
      ;;
  esac
done

quality_args=(--no-fatal-warnings --no-fatal-infos)
if [[ "$strict" == true ]]; then
  quality_args=(--fatal-warnings --fatal-infos)
fi

cd "$repo_root"
fvm flutter analyze lib test "${quality_args[@]}" "${analyze_args[@]}"