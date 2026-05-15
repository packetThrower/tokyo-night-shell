# Starship — palette tracks macOS Appearance, live.
# Two cache files (one per palette) generated from the source; a precmd hook
# re-picks the active one before each prompt. Toggling System Settings →
# Appearance takes effect within one prompt, no restart needed.
zmodload zsh/datetime  # exposes $EPOCHSECONDS

__starship_setup_caches() {
  local src="$HOME/.config/starship.toml"
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  mkdir -p "$dir"
  for variant in tokyo_night tokyo_night_day; do
    local cache="$dir/starship-${variant}.toml"
    if [[ ! -f "$cache" ]] || [[ "$src" -nt "$cache" ]]; then
      sed -E "s|^palette = \".*\"|palette = \"$variant\"|" "$src" > "$cache"
    fi
  done
}

# Debounced appearance check — `defaults read` is ~10ms; this caps it at
# once per 3 seconds so it can't slow rapid prompts.
__starship_last_appearance_check=0
__starship_pick_palette() {
  local now=$EPOCHSECONDS
  (( now - __starship_last_appearance_check < 3 )) && return
  __starship_last_appearance_check=$now
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
    export STARSHIP_CONFIG="$dir/starship-tokyo_night.toml"
  else
    export STARSHIP_CONFIG="$dir/starship-tokyo_night_day.toml"
  fi
}

# Manual sync — call after editing ~/.config/starship.toml so caches regen.
starship-resync() {
  __starship_setup_caches
  __starship_last_appearance_check=0
  __starship_pick_palette
  echo "STARSHIP_CONFIG=$STARSHIP_CONFIG"
}

__starship_setup_caches
__starship_pick_palette
autoload -Uz add-zsh-hook
add-zsh-hook precmd __starship_pick_palette

eval "$(starship init zsh)"

# Zellij — pick theme at launch from macOS Appearance. Zellij reads its config
# once at startup and can't live-swap, so an open session keeps the theme it
# was started with; toggle Appearance before launching a new session.
# The wrapper points zellij at a cached copy of config.kdl with the
# `theme "..."` line patched in, leaving the real config untouched.
__zellij_setup_caches() {
  local src="$HOME/.config/zellij/config.kdl"
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  mkdir -p "$dir"
  for variant in tokyo-night tokyo-night-day; do
    local cache="$dir/zellij-${variant}.kdl"
    if [[ ! -f "$cache" ]] || { [[ -f "$src" ]] && [[ "$src" -nt "$cache" ]]; }; then
      {
        printf 'theme "%s"\n\n' "$variant"
        [[ -f "$src" ]] && sed -E '/^[[:space:]]*(\/\/[[:space:]]*)?theme[[:space:]]+"[^"]*"[[:space:]]*$/d' "$src"
      } > "$cache"
    fi
  done
}

zellij() {
  # Zellij sets $ZELLIJ inside an active session. Nesting zellij-in-zellij
  # double-draws tab/status bars and wastes a session; bail with a hint.
  if [[ -n "$ZELLIJ" && $# -eq 0 ]]; then
    echo "Already inside zellij (session: ${ZELLIJ_SESSION_NAME:-?}). Use Ctrl+O for the session manager, or 'command zellij ...' to force." >&2
    return 1
  fi
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  [[ -f "$dir/zellij-tokyo-night.kdl" && -f "$dir/zellij-tokyo-night-day.kdl" ]] || __zellij_setup_caches
  local variant=tokyo-night
  defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark || variant=tokyo-night-day
  ZELLIJ_CONFIG_FILE="$dir/zellij-${variant}.kdl" command zellij "$@"
}

# Manual sync — call after editing ~/.config/zellij/config.kdl so caches regen.
# Running zellij sessions need a restart to pick up changes.
zellij-resync() {
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  rm -f "$dir/zellij-tokyo-night.kdl" "$dir/zellij-tokyo-night-day.kdl"
  __zellij_setup_caches
  echo "Zellij caches refreshed."
}

__zellij_setup_caches
