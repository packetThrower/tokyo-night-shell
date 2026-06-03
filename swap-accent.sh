#!/usr/bin/env bash
# Swap the focus accent across WezTerm, Starship, and Zellij in one shot.
# Edits both the repo source and the installed configs so they stay in sync.
#
# Usage:
#   ./swap-accent.sh <color>
#
# Colors: blue cyan magenta green yellow red orange
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf "  \033[1;34m›\033[0m %s\n" "$*"; }
ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
fail() { printf "  \033[1;31m✗\033[0m %s\n" "$*" >&2; exit 1; }

# Capture a file's mode in octal — `tmp file + mv` would otherwise reset
# permissions to default. BSD stat (macOS) vs GNU stat (Linux).
_mode() { stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1"; }

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") <color>

Swaps the focus accent (prompt ❯, WezTerm active tab, Zellij active ribbon
and pane border) to one of the named Tokyo Night palette colors.

  blue     #7aa2f7 / #1f5fcc   (default)
  cyan     #7dcfff / #005d7a
  magenta  #bb9af7 / #6a1fbf
  green    #9ece6a / #3d5520
  yellow   #e0af68 / #5f4419
  red      #f7768e / #c80f4a
  orange   #ff9e64 / #8a4400
EOF
  exit 1
}

case "${1:-}" in
  blue)    DARK="#7aa2f7"; DAY="#1f5fcc" ;;
  cyan)    DARK="#7dcfff"; DAY="#005d7a" ;;
  magenta) DARK="#bb9af7"; DAY="#6a1fbf" ;;
  green)   DARK="#9ece6a"; DAY="#3d5520" ;;
  yellow)  DARK="#e0af68"; DAY="#5f4419" ;;
  red)     DARK="#f7768e"; DAY="#c80f4a" ;;
  orange)  DARK="#ff9e64"; DAY="#8a4400" ;;
  ""|-h|--help) usage ;;
  *)       fail "Unknown color: $1 (run with no args for the list)" ;;
esac

COLOR="$1"

# WezTerm: rewrite `local ACCENT_NAME = '<color>'` near the top.
swap_wezterm() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  local mode; mode=$(_mode "$f")
  sed -E "s/(local ACCENT_NAME = ')[a-z]+(')/\\1${COLOR}\\2/" "$f" > "$f.tmp" \
    && mv "$f.tmp" "$f" && chmod "$mode" "$f"
  ok "WezTerm:  ${f/#$HOME/~}"
}

# Starship: replace the `accent = "..."` line in each palette block.
# Awk tracks which palette we're inside so we hit the right one with the
# right hex; other named colors (blue, cyan, etc.) are left alone.
swap_starship() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  local mode; mode=$(_mode "$f")
  awk -v dark="$DARK" -v day="$DAY" '
    /^\[palettes\.tokyo_night\][[:space:]]*$/     { p = "dark"; print; next }
    /^\[palettes\.tokyo_night_day\][[:space:]]*$/ { p = "day";  print; next }
    /^accent[[:space:]]*=/ {
      if (p == "dark")     { sub(/"[^"]*"/, "\"" dark "\"") }
      else if (p == "day") { sub(/"[^"]*"/, "\"" day "\"") }
    }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f" && chmod "$mode" "$f"
  ok "Starship: ${f/#$HOME/~}"
}

# Zellij: rewrite ribbon_selected.background and frame_selected.base.
# Block-aware via simple { } depth so we don't touch identical hexes
# elsewhere (e.g. multiplayer_user_colors.player_2).
swap_zellij() {
  local f="$1"
  local hex="$2"
  [[ -f "$f" ]] || return 0
  local mode; mode=$(_mode "$f")
  awk -v hex="$hex" '
    /^[[:space:]]*ribbon_selected[[:space:]]*\{/ { in_ribbon = 1 }
    /^[[:space:]]*frame_selected[[:space:]]*\{/  { in_frame  = 1 }
    /^[[:space:]]*\}/                            { in_ribbon = 0; in_frame = 0 }
    in_ribbon && /^[[:space:]]*background[[:space:]]+"/ { sub(/"[^"]*"/, "\"" hex "\"") }
    in_frame  && /^[[:space:]]*base[[:space:]]+"/       { sub(/"[^"]*"/, "\"" hex "\"") }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f" && chmod "$mode" "$f"
  ok "Zellij:   ${f/#$HOME/~}"
}

echo "Swapping accent → ${COLOR} (dark ${DARK}, day ${DAY})"
echo

info "Repo source"
swap_wezterm  "$SCRIPT_DIR/wezterm/wezterm.lua"
swap_starship "$SCRIPT_DIR/starship/starship.toml"
swap_zellij   "$SCRIPT_DIR/zellij/themes/tokyo-night.kdl"     "$DARK"
swap_zellij   "$SCRIPT_DIR/zellij/themes/tokyo-night-day.kdl" "$DAY"

echo
info "Installed configs"
swap_wezterm  "$HOME/.wezterm.lua"
swap_starship "$HOME/.config/starship.toml"
swap_zellij   "$HOME/.config/zellij/themes/tokyo-night.kdl"     "$DARK"
swap_zellij   "$HOME/.config/zellij/themes/tokyo-night-day.kdl" "$DAY"

echo
echo "Applied. Effects:"
echo "  • WezTerm  — reloads live (any open window)"
echo "  • Starship — refreshes on the next prompt (cache regen via mtime)"
echo "  • Zellij   — restart sessions to apply:  zellij ka && zellij"
