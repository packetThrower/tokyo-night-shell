#!/usr/bin/env bash
# Tokyo Night Shell — uninstaller.
# Restores the most recent backups of touched files and removes the managed
# block from ~/.zshrc. Does NOT uninstall WezTerm/Starship/the font.
set -euo pipefail

MARKER_BEGIN="# >>> tokyo-night-shell init >>>"
MARKER_END="# <<< tokyo-night-shell init <<<"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"

info() { printf "  \033[1;34m›\033[0m %s\n" "$*"; }
ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m!\033[0m %s\n" "$*"; }

restore_latest_backup() {
  local target="$1"
  local latest
  latest=$(ls -1t "${target}".bak.* 2>/dev/null | head -1 || true)
  if [[ -n "$latest" ]]; then
    cp -p "$latest" "$target"
    ok "Restored ${target/#$HOME/~} from ${latest/#$HOME/~}"
  else
    warn "No backup found for ${target/#$HOME/~} — leaving current file in place."
  fi
}

restore_latest_backup "$HOME/.wezterm.lua"
restore_latest_backup "$HOME/.config/starship.toml"

if [[ -f "$ZSHRC" ]] && grep -qF "$MARKER_BEGIN" "$ZSHRC"; then
  awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
    $0 ~ b {inblock=1; next}
    $0 ~ e {inblock=0; next}
    !inblock {print}
  ' "$ZSHRC" > "${ZSHRC}.tmp" && mv "${ZSHRC}.tmp" "$ZSHRC"
  ok "Removed managed block from ${ZSHRC/#$HOME/~}"
fi

rm -f "$HOME/.cache/starship-tokyo_night.toml" \
      "$HOME/.cache/starship-tokyo_night_day.toml"
ok "Cleared starship caches."

rm -f "$HOME/.config/zellij/themes/tokyo-night.kdl" \
      "$HOME/.config/zellij/themes/tokyo-night-day.kdl" \
      "$HOME/.cache/zellij-tokyo-night.kdl" \
      "$HOME/.cache/zellij-tokyo-night-day.kdl"
ok "Removed zellij themes and caches."

echo
ok "Uninstall complete. Open a new shell to drop the hook."
