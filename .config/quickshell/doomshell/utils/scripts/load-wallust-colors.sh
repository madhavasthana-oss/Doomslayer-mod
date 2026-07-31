#!/usr/bin/env bash
# load-wallust-colors.sh — generate + activate wallust palette for doomshell
#
# Usage:
#   load-wallust-colors.sh                 # wallpaper from running awww, then activate
#   load-wallust-colors.sh --from-awww     # same (explicit)
#   load-wallust-colors.sh /path/to/img    # wallust that image, then activate
#   load-wallust-colors.sh --activate      # only promote existing wallust-colors.json
#   load-wallust-colors.sh --status
#
# Theme.qml watches: <doomshell>/colors/active-colors.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOMSHELL_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COLORS_DIR="${DOOMSHELL_DIR}/colors"
WALLUST_JSON="${COLORS_DIR}/wallust-colors.json"
ACTIVE_JSON="${COLORS_DIR}/active-colors.json"
SOURCE_FILE="${COLORS_DIR}/source"

usage() {
    sed -n '2,12p' "$0" | sed 's/^# \?//'
    exit 0
}

# Parse `awww query` lines like:
#   : eDP-1: 1920x1080, scale: 1, currently displaying: image: /path/to/wall.jpg
# Prefer the first monitor that reports an image path.
get_awww_wallpaper() {
    if ! command -v awww >/dev/null 2>&1; then
        echo "error: awww not found in PATH" >&2
        return 1
    fi
    if ! pgrep -u "$USER" -x awww-daemon >/dev/null 2>&1; then
        echo "error: awww-daemon is not running" >&2
        return 1
    fi

    local line path
    while IFS= read -r line; do
        # "image: /absolute/or/relative/path"
        if [[ "$line" =~ currently\ displaying:\ image:\ (.+)$ ]]; then
            path="${BASH_REMATCH[1]}"
            path="${path%%$'\r'}"
            path="${path%"${path##*[![:space:]]}"}"  # rtrim
        elif [[ "$line" =~ image:\ (/[^[:space:]].*)$ ]]; then
            path="${BASH_REMATCH[1]}"
            path="${path%%$'\r'}"
            path="${path%"${path##*[![:space:]]}"}"
        else
            continue
        fi

        # Resolve if possible
        if [[ -f "$path" ]]; then
            readlink -f "$path"
            return 0
        fi
        # Sometimes awww prints a path that exists relative to $HOME
        if [[ -f "$HOME/$path" ]]; then
            readlink -f "$HOME/$path"
            return 0
        fi
    done < <(awww query 2>/dev/null || true)

    echo "error: awww query did not report a current image path" >&2
    awww query 2>&1 | sed 's/^/  /' >&2 || true
    return 1
}

activate_wallust() {
    mkdir -p "$COLORS_DIR"
    if [[ ! -f "$WALLUST_JSON" ]]; then
        echo "error: missing $WALLUST_JSON" >&2
        echo "hint: run with --from-awww or a wallpaper path first" >&2
        exit 1
    fi
    python3 - "$WALLUST_JSON" <<'PY'
import json, sys
required = [
    "bgPrimary", "bgSurface", "bgElevated",
    "accent", "accentWarm", "accentSoft",
    "textPrimary", "textSecondary", "textMuted", "textDim",
    "stateCritical", "stateSafe", "stateWarning",
    "borderActive", "borderIdle",
    "bgConsole", "borderConsole", "glowConsole",
]
data = json.load(open(sys.argv[1]))
missing = [k for k in required if k not in data or not str(data[k]).strip()]
if missing:
    sys.stderr.write("error: wallust-colors.json missing keys: " + ", ".join(missing) + "\n")
    sys.exit(1)
PY
    cp -f "$WALLUST_JSON" "${ACTIVE_JSON}.tmp"
    mv -f "${ACTIVE_JSON}.tmp" "$ACTIVE_JSON"
    printf 'wallust\n' > "$SOURCE_FILE"
    echo "activated: wallust → $ACTIVE_JSON"
}

run_wallust_on() {
    local img="$1"
    if ! command -v wallust >/dev/null 2>&1; then
        echo "error: wallust not found in PATH" >&2
        exit 1
    fi
    if [[ ! -f "$img" ]]; then
        echo "error: not a file: $img" >&2
        exit 1
    fi
    echo "wallust: $img"
    # -s: skip terminal sequences (shell chrome only)
    wallust run -s "$img"
}

status() {
    local src="(none)"
    [[ -f "$SOURCE_FILE" ]] && src="$(tr -d '\n' < "$SOURCE_FILE")"
    echo "doomshell:  $DOOMSHELL_DIR"
    echo "source:     $src"
    echo "wallust:    $WALLUST_JSON$([ -f "$WALLUST_JSON" ] && echo ' (ok)' || echo ' (missing)')"
    echo "active:     $ACTIVE_JSON$([ -f "$ACTIVE_JSON" ] && echo ' (ok)' || echo ' (missing)')"
    if command -v awww >/dev/null 2>&1 && pgrep -u "$USER" -x awww-daemon >/dev/null 2>&1; then
        local cur
        if cur="$(get_awww_wallpaper 2>/dev/null)"; then
            echo "awww image: $cur"
        else
            echo "awww image: (unavailable)"
        fi
    else
        echo "awww image: (daemon not running)"
    fi
}

ACTION="from-awww"
WALL_IMG=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        --status) ACTION="status" ;;
        --activate) ACTION="activate" ;;
        --from-awww) ACTION="from-awww" ;;
        *)
            WALL_IMG="$1"
            ACTION="run-path"
            ;;
    esac
    shift
done

case "$ACTION" in
    status)
        status
        ;;
    activate)
        activate_wallust
        status
        ;;
    from-awww)
        WALL_IMG="$(get_awww_wallpaper)"
        run_wallust_on "$WALL_IMG"
        activate_wallust
        status
        ;;
    run-path)
        run_wallust_on "$WALL_IMG"
        activate_wallust
        status
        ;;
esac
