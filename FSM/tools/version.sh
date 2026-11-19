#!/bin/bash
# Resolve installation identity or export a committed release. Bash 3.2+.
set -euo pipefail

FSM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
die() { echo "ERROR: $*" >&2; exit 1; }

validate() {
  [[ ${#VERSION} -le 40 && $VERSION =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.[1-9][0-9]*$ ]] ||
    die "Invalid version; expected Major.Minor.CommitCount."
  [[ $COMMIT =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]] || die "Invalid full Git commit hash."
}

CHECKOUT=false
if ROOT="$(git -C "$FSM_DIR" rev-parse --show-toplevel 2>/dev/null)"; then
  if git -C "$FSM_DIR" ls-files --error-unmatch fsm.sh >/dev/null 2>&1; then
    CHECKOUT=true
    PREFIX="$(git -C "$FSM_DIR" rev-parse --show-prefix)"
    [[ $(git -C "$ROOT" rev-parse --is-shallow-repository) == false ]] ||
      die "Full Git history required; fetch the complete history first."
    [[ -z $(git -C "$ROOT" status --porcelain --untracked-files=all) ]] ||
      die "Local changes found; commit or remove them before installing/exporting."
    COMMIT="$(git -C "$ROOT" rev-parse HEAD)"
    BASE="$(git -C "$ROOT" show "${COMMIT}:VERSION")"
    BASE="${BASE%$'\r'}"
    [[ $BASE =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] ||
      die "VERSION must contain Major.Minor, for example 1.0."
    COUNT="$(git -C "$ROOT" rev-list --count "$COMMIT")"
    VERSION="${BASE}.${COUNT}"
  elif [[ $(cd "$FSM_DIR/.." && pwd -P) == "$ROOT" ]]; then
    die "FSM sources are not tracked in this checkout."
  fi
else
  # Do not allow prepared metadata to hide a broken/unavailable Git checkout.
  PARENT="$FSM_DIR"
  while :; do
    [[ ! -e "$PARENT/.git" ]] || die "Cannot inspect the Git checkout; install/fix Git first."
    [[ $PARENT != / ]] || break
    PARENT="${PARENT%/*}"
    PARENT="${PARENT:-/}"
  done
fi

if [[ $CHECKOUT == false ]]; then
  METADATA="$FSM_DIR/install_scripts/release-version.txt"
  [[ -f $METADATA ]] || die "No Git checkout or prepared release metadata found."
  LINES=()
  while IFS= read -r LINE || [[ -n $LINE ]]; do
    LINES+=("${LINE%$'\r'}")
  done < "$METADATA"
  [[ ${#LINES[@]} == 2 ]] || die "Release metadata must contain exactly version and commit on two lines."
  VERSION="${LINES[0]}"
  COMMIT="${LINES[1]}"
fi
validate

case "${1:-}" in
  resolve)
    [[ $# == 1 ]] || die "Usage: version.sh resolve"
    ;;
  export)
    [[ $# == 2 ]] || die "Usage: version.sh export destination.zip"
    [[ $CHECKOUT == true ]] || die "Export requires a clean, complete Git checkout."
    [[ ! -e $2 ]] || die "Destination already exists."
    command -v zip >/dev/null || die "ZIP export requires the zip utility."
    METADATA="${PREFIX}install_scripts/release-version.txt"
    if git -C "$ROOT" cat-file -e "${COMMIT}:${METADATA}" 2>/dev/null; then
      die "Release metadata must not be committed to Git."
    fi
    TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TEMP_DIR"' EXIT
    git -C "$ROOT" archive --format=zip --output="$TEMP_DIR/release.zip" "$COMMIT"
    mkdir -p "$TEMP_DIR/$(dirname "$METADATA")"
    printf '%s\n%s\n' "$VERSION" "$COMMIT" > "$TEMP_DIR/$METADATA"
    (cd "$TEMP_DIR"; zip -q release.zip "$METADATA")
    # Noclobber also refuses an output created concurrently with this export.
    (set -C; cat "$TEMP_DIR/release.zip" > "$2")
    ;;
  *) die "Usage: version.sh resolve | export destination.zip" ;;
esac
printf '%s %s\n' "$VERSION" "$COMMIT"
