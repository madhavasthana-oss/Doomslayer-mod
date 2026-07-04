#!/usr/bin/env bash
# Switch the system default terminal between Ghostty and Kitty.
# Usage: switch_terminal.sh --T Ghostty
#        switch_terminal.sh --T Kitty

set -euo pipefail

HYDE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hyde/config.toml"
XDG_TERMINALS="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-terminals.list"
PYPR_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/pypr/config.toml"
ENV_THEME="${XDG_DATA_HOME:-$HOME/.local/share}/hyde/env-theme"
THEME_ENV="${XDG_DATA_HOME:-$HOME/.local/share}/hyde/theme-env"
HYDE_PARSE="${XDG_DATA_HOME:-$HOME/.local/share}/../lib/hyde/parse.config.py"
XDG_TERMINAL_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/xdg-terminal-exec"

usage() {
    cat <<EOF
Usage:
  switch_terminal.sh --T Ghostty
  switch_terminal.sh --T Kitty
  switch_terminal.sh -T ghostty
  switch_terminal.sh -T kitty

Switches the default terminal across HyDE, xdg-terminal-exec,
Pypr scratchpads, and related environment files.
EOF
    exit 1
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "Doomslayer" "Terminal switched" "Default terminal is now $1"
    fi
}

current_terminal() {
    if [[ -f "$ENV_THEME" ]]; then
        sed -n 's/^TERMINAL="\([^"]*\)".*/\1/p' "$ENV_THEME" | head -1
    fi
}

normalize_terminal() {
    local raw="${1,,}"
    case "$raw" in
        ghostty|ghost) echo "ghostty" ;;
        kitty|kit)     echo "kitty" ;;
        *)             return 1 ;;
    esac
}

desktop_for_terminal() {
    case "$1" in
        ghostty) echo "com.mitchellh.ghostty.desktop" ;;
        kitty)   echo "kitty.desktop" ;;
    esac
}

pypr_term_with_class() {
    case "$1" in
        ghostty) echo 'term_with_class = "ghostty --class"' ;;
        kitty)   echo 'term_with_class = "kitty --class"' ;;
    esac
}

update_hyde_config() {
    local term="$1"
    [[ -f "$HYDE_CONFIG" ]] || return 0
    sed -i \
        -e "s/^terminal = \".*\"/terminal = \"$term\"/" \
        -e "s/^quickapps = \".*\"/quickapps = \"$term\"/" \
        "$HYDE_CONFIG"
}

update_env_files() {
    local term="$1"
    for file in "$ENV_THEME" "$THEME_ENV"; do
        [[ -f "$file" ]] || continue
        sed -i "s/^TERMINAL=\".*\"/TERMINAL=\"$term\"/" "$file"
    done
}

update_xdg_terminals() {
    local primary="$1"
    local secondary
    case "$primary" in
        ghostty) secondary="kitty.desktop" ;;
        kitty)   secondary="com.mitchellh.ghostty.desktop" ;;
    esac

    cat >"$XDG_TERMINALS" <<EOF
# See https://github.com/Vladimir-csp/xdg-terminal-exec?tab=readme-ov-file#configuration
$(desktop_for_terminal "$primary")
$secondary
Alacritty.desktop
foot.desktop
EOF
}

update_pypr_config() {
    local term="$1"
    [[ -f "$PYPR_CONFIG" ]] || return 0
    local replacement
    replacement="$(pypr_term_with_class "$term")"
    sed -i "s|^term_with_class = .*|$replacement|" "$PYPR_CONFIG"
}

apply_runtime() {
    if [[ -f "$HYDE_PARSE" ]]; then
        python3 "$HYDE_PARSE" --input "$HYDE_CONFIG" >/dev/null 2>&1 || true
    fi
    rm -f "$XDG_TERMINAL_CACHE"
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
    fi
}

TARGET=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -T|--T)
            [[ $# -lt 2 ]] && usage
            TARGET="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

[[ -n "$TARGET" ]] || usage

TERM="$(normalize_terminal "$TARGET")" || {
    echo "error: unknown terminal '$TARGET' (use Ghostty or Kitty)" >&2
    exit 1
}

CURRENT="$(current_terminal || true)"
if [[ "$CURRENT" == "$TERM" ]]; then
    echo "Default terminal is already $TERM."
    exit 0
fi

update_hyde_config "$TERM"
update_env_files "$TERM"
update_xdg_terminals "$TERM"
update_pypr_config "$TERM"
apply_runtime

echo "Default terminal switched to $TERM."
notify "$TERM"