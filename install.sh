#!/usr/bin/env bash
# Tokyo Night Shell — installer.
# Copies WezTerm + Starship configs into place, installs JetBrainsMono Nerd
# Font if missing, and wires a managed block into ~/.zshrc.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
MARKER_BEGIN="# >>> tokyo-night-shell init >>>"
MARKER_END="# <<< tokyo-night-shell init <<<"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"

info() { printf "  \033[1;34m›\033[0m %s\n" "$*"; }
ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m!\033[0m %s\n" "$*"; }
fail() { printf "  \033[1;31m✗\033[0m %s\n" "$*" >&2; exit 1; }

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

backup_if_exists() {
  local f="$1"
  if [[ -e "$f" && ! -L "$f" ]]; then
    cp -p "$f" "${f}.bak.${TIMESTAMP}"
    info "Backed up ${f/#$HOME/~} → ${f/#$HOME/~}.bak.${TIMESTAMP}"
  fi
}

# ─── 0. Sanity ────────────────────────────────────────────────────────────────
is_macos || warn "Not macOS — light/dark auto-switch will stay on the day palette."

# ─── 1. Required tools ────────────────────────────────────────────────────────
need_brew=false
command -v wezterm  >/dev/null 2>&1 || need_brew=true
command -v starship >/dev/null 2>&1 || need_brew=true

if $need_brew; then
  if ! command -v brew >/dev/null 2>&1; then
    fail "Homebrew not found. Install from https://brew.sh, then re-run."
  fi
fi

if ! command -v wezterm >/dev/null 2>&1; then
  info "Installing WezTerm via Homebrew..."
  brew install --cask wezterm
fi
ok "WezTerm: $(wezterm --version | head -1)"

if ! command -v starship >/dev/null 2>&1; then
  info "Installing Starship via Homebrew..."
  brew install starship
fi
ok "Starship: $(starship --version | head -1)"

# ─── 2. Font ──────────────────────────────────────────────────────────────────
if is_macos && command -v brew >/dev/null 2>&1; then
  if ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi 'jetbrains.*mono.*nerd'; then
    ok "JetBrainsMono Nerd Font already installed."
  else
    info "Installing JetBrainsMono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font
    ok "Font installed."
  fi
fi

# ─── 3. Configs ───────────────────────────────────────────────────────────────
mkdir -p "$HOME/.config"

backup_if_exists "$HOME/.wezterm.lua"
cp "$SCRIPT_DIR/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
ok "Installed ~/.wezterm.lua"

backup_if_exists "$HOME/.config/starship.toml"
cp "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
ok "Installed ~/.config/starship.toml"

# ─── 4. Zellij themes ─────────────────────────────────────────────────────────
# Additive — drop theme files into ~/.config/zellij/themes/ and let the shell
# wrapper handle activation. The user's own ~/.config/zellij/config.kdl is
# never touched.
mkdir -p "$HOME/.config/zellij/themes"
for theme in tokyo-night tokyo-night-day; do
  dest="$HOME/.config/zellij/themes/${theme}.kdl"
  backup_if_exists "$dest"
  cp "$SCRIPT_DIR/zellij/themes/${theme}.kdl" "$dest"
  ok "Installed ~/.config/zellij/themes/${theme}.kdl"
done

if command -v zellij >/dev/null 2>&1; then
  ok "Zellij: $(zellij --version)"
else
  info "Zellij not installed — themes are in place for later (brew install zellij)."
fi

# ─── 5. .zshrc managed block ──────────────────────────────────────────────────
touch "$ZSHRC"

if grep -qF "$MARKER_BEGIN" "$ZSHRC"; then
  info "Refreshing existing tokyo-night-shell block in ${ZSHRC/#$HOME/~}..."
  awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
    $0 ~ b {inblock=1; next}
    $0 ~ e {inblock=0; next}
    !inblock {print}
  ' "$ZSHRC" > "${ZSHRC}.tmp" && mv "${ZSHRC}.tmp" "$ZSHRC"
else
  backup_if_exists "$ZSHRC"
fi

{
  echo ""
  echo "$MARKER_BEGIN"
  cat "$SCRIPT_DIR/shell/zshrc-init.zsh"
  echo "$MARKER_END"
} >> "$ZSHRC"
ok "Wired ${ZSHRC/#$HOME/~}"

# ─── Done ─────────────────────────────────────────────────────────────────────
echo
ok "Install complete."
echo
echo "  Next:"
echo "    1. Open a fresh WezTerm window (or run 'exec zsh' in this one)."
echo "    2. Toggle System Settings → Appearance to see live theme swap."
echo
echo "  To uninstall later:  ./uninstall.sh"
