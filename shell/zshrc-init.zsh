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
