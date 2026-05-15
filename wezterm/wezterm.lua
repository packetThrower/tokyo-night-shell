-- ~/.wezterm.lua
-- Tokyo Night · JetBrains Mono Nerd Font · macOS vibrancy · fancy tab bar

local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ────────────────────────────────────────────────────────────────────────────
-- Colors — auto-switch with macOS appearance
-- ────────────────────────────────────────────────────────────────────────────
local palettes = {
  dark = {
    bg          = '#1a1b26',
    bg_dim      = '#16161e',
    bg_highlight= '#292e42',
    fg          = '#c0caf5',
    fg_dim      = '#a9b1d6',
    comment     = '#565f89',
    blue        = '#7aa2f7',
    cyan        = '#7dcfff',
    magenta     = '#bb9af7',
    green       = '#9ece6a',
    yellow      = '#e0af68',
    red         = '#f7768e',
    tab_bar_bg  = 'rgba(26, 27, 38, 0.0)',
    tab_inactive= 'rgba(26, 27, 38, 0.35)',
  },
  day = {
    bg          = '#e1e2e7',
    bg_dim      = '#d0d5e3',
    bg_highlight= '#c4c8da',
    fg          = '#3760bf',
    fg_dim      = '#6172b0',
    comment     = '#848cb5',
    blue        = '#2e7de9',
    cyan        = '#007197',
    magenta     = '#9854f1',
    green       = '#587539',
    yellow      = '#8c6c3e',
    red         = '#f52a65',
    tab_bar_bg  = 'rgba(225, 226, 231, 0.0)',
    tab_inactive= 'rgba(225, 226, 231, 0.45)',
  },
}

local function theme_for(appearance)
  if appearance and appearance:find('Dark') then
    return 'Tokyo Night', palettes.dark
  end
  return 'Tokyo Night Day', palettes.day
end

local function colors_for(p)
  return {
    cursor_bg = p.cyan,
    cursor_border = p.cyan,
    cursor_fg = p.bg,
    selection_bg = p.bg_highlight,
    selection_fg = p.fg,
    split = p.bg_highlight,
    tab_bar = {
      -- Solid colors here — rgba lets the vibrancy/blur bleed through and washes
      -- the tabs out into a frosted-glass white. Opaque chrome, translucent body.
      background = p.bg,
      active_tab = {
        bg_color = p.bg,
        fg_color = p.blue,
        intensity = 'Bold',
      },
      inactive_tab = {
        bg_color = p.bg_dim,
        fg_color = p.comment,
      },
      inactive_tab_hover = {
        bg_color = p.bg_highlight,
        fg_color = p.fg,
        italic = false,
      },
      new_tab = {
        bg_color = p.bg,
        fg_color = p.blue,
      },
      new_tab_hover = {
        bg_color = p.bg_highlight,
        fg_color = p.cyan,
      },
    },
  }
end

-- Fancy tab bar uses its own font for tab titles (otherwise system font, no
-- Nerd Font glyphs). Mirror the theme so the chrome blends with the body.
local function frame_for(p)
  return {
    font = wezterm.font({ family = 'JetBrainsMono Nerd Font', weight = 'Medium' }),
    font_size = 11.5,
    active_titlebar_bg = p.bg,
    inactive_titlebar_bg = p.bg,
    active_titlebar_fg = p.fg_dim,
    inactive_titlebar_fg = p.comment,
    active_titlebar_border_bottom = p.bg_highlight,
    inactive_titlebar_border_bottom = p.bg_highlight,
    button_fg = p.comment,
    button_bg = p.bg,
    button_hover_fg = p.fg,
    button_hover_bg = p.bg_highlight,
  }
end

-- Pick the right palette at config-load time; live-switch handled below.
local initial_appearance = (wezterm.gui and wezterm.gui.get_appearance and wezterm.gui.get_appearance()) or 'Dark'
local initial_scheme, palette = theme_for(initial_appearance)
config.color_scheme = initial_scheme
config.colors = colors_for(palette)
config.window_frame = frame_for(palette)

-- ────────────────────────────────────────────────────────────────────────────
-- Font
-- ────────────────────────────────────────────────────────────────────────────
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  { family = 'JetBrains Mono',          weight = 'Medium' },
  'SF Mono',
  'Menlo',
  'Apple Color Emoji',
}
config.font_size = 14.0
config.line_height = 1.15
config.cell_width = 1.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
config.bold_brightens_ansi_colors = true
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'
config.warn_about_missing_glyphs = false

-- ────────────────────────────────────────────────────────────────────────────
-- Window: native title, vibrancy + blur, comfortable padding
-- ────────────────────────────────────────────────────────────────────────────
config.window_decorations = 'TITLE | RESIZE'
config.window_background_opacity = 0.82
config.macos_window_background_blur = 32
config.window_padding = {
  left = 18, right = 18, top = 8, bottom = 10,
}
config.initial_cols = 160
config.initial_rows = 45
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 60,
  fade_out_duration_ms = 180,
  target = 'CursorColor',
}

-- Subtle dim on inactive splits — focus on the active one
config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.70,
}

-- ────────────────────────────────────────────────────────────────────────────
-- Cursor
-- ────────────────────────────────────────────────────────────────────────────
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'EaseOut'
config.cursor_blink_ease_out = 'EaseIn'
config.animation_fps = 60

-- ────────────────────────────────────────────────────────────────────────────
-- Scrollback
-- ────────────────────────────────────────────────────────────────────────────
config.enable_scroll_bar = false
config.scrollback_lines = 50000

-- ────────────────────────────────────────────────────────────────────────────
-- Tab bar
-- ────────────────────────────────────────────────────────────────────────────
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 36

-- React to macOS Appearance changes (System Settings → Appearance, or auto).
wezterm.on('window-config-reloaded', function(window)
  local appearance = window:get_appearance()
  local scheme, p = theme_for(appearance)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    overrides.colors = colors_for(p)
    overrides.window_frame = frame_for(p)
    palette = p
    window:set_config_overrides(overrides)
  end
end)

-- Map foreground process names → Nerd Font glyphs
local function icon_for(process)
  local nf = wezterm.nerdfonts
  local icons = {
    ['nvim']     = nf.custom_vim,
    ['vim']      = nf.custom_vim,
    ['vi']       = nf.custom_vim,
    ['nano']     = nf.fa_file_text_o,
    ['node']     = nf.dev_nodejs_small,
    ['deno']     = nf.seti_deno,
    ['bun']      = nf.md_food_croissant,
    ['python']   = nf.dev_python,
    ['python3']  = nf.dev_python,
    ['ruby']     = nf.cod_ruby,
    ['cargo']    = nf.dev_rust,
    ['rustc']    = nf.dev_rust,
    ['go']       = nf.seti_go,
    ['ssh']      = nf.fa_server,
    ['git']      = nf.dev_git,
    ['lazygit']  = nf.dev_git,
    ['gh']       = nf.dev_github_badge,
    ['docker']   = nf.linux_docker,
    ['kubectl']  = nf.linux_docker,
    ['htop']     = nf.mdi_chart_areaspline,
    ['btop']     = nf.mdi_chart_areaspline,
    ['top']      = nf.mdi_chart_areaspline,
    ['bash']     = nf.cod_terminal_bash,
    ['zsh']      = nf.dev_terminal,
    ['fish']     = nf.md_fish,
    ['claude']   = nf.fa_star,
    ['curl']     = nf.md_download,
    ['wget']     = nf.md_download,
    ['make']     = nf.seti_makefile,
    ['less']     = nf.fa_file_text_o,
    ['man']      = nf.fa_book,
  }
  return icons[process] or nf.cod_terminal
end

-- Tab title: " <icon>  <process|cwd>  "
wezterm.on('format-tab-title', function(tab, _, _, _, _, max_width)
  local pane = tab.active_pane
  local process = (pane.foreground_process_name or ''):match('([^/\\]+)$') or 'shell'
  local icon = icon_for(process)

  local label
  if tab.tab_title and #tab.tab_title > 0 then
    label = tab.tab_title
  else
    local cwd = ''
    if pane.current_working_dir then
      cwd = pane.current_working_dir.file_path or tostring(pane.current_working_dir)
      cwd = cwd:gsub('/$', '')
    end
    if cwd == wezterm.home_dir or cwd == '' then
      label = process
    else
      label = cwd:match('([^/]+)$') or process
    end
  end

  local title = string.format('  %s  %s  ', icon, label)
  if #title > max_width then
    title = wezterm.truncate_right(title, max_width - 1) .. '…'
  end

  return { { Text = title } }
end)

-- Right status: workspace · battery · clock
wezterm.on('update-right-status', function(window, _)
  local nf = wezterm.nerdfonts
  local cells = {}

  local ws = window:active_workspace()
  if ws and ws ~= 'default' then
    table.insert(cells, { Foreground = { Color = palette.magenta } })
    table.insert(cells, { Text = ' ' .. nf.cod_window .. '  ' .. ws })
  end

  for _, b in ipairs(wezterm.battery_info()) do
    local pct = b.state_of_charge * 100
    local glyph = nf.md_battery
    if pct < 20 then glyph = nf.md_battery_20
    elseif pct < 40 then glyph = nf.md_battery_40
    elseif pct < 60 then glyph = nf.md_battery_60
    elseif pct < 80 then glyph = nf.md_battery_80 end
    if b.state == 'Charging' then glyph = nf.md_battery_charging end
    table.insert(cells, { Foreground = { Color = palette.comment } })
    table.insert(cells, { Text = '   ' })
    table.insert(cells, { Foreground = { Color = pct < 20 and palette.red or palette.green } })
    table.insert(cells, { Text = glyph .. ' ' .. string.format('%.0f%%', pct) })
  end

  table.insert(cells, { Foreground = { Color = palette.comment } })
  table.insert(cells, { Text = '   ' })
  table.insert(cells, { Foreground = { Color = palette.fg_dim } })
  table.insert(cells, { Text = nf.md_clock_outline .. ' ' .. wezterm.strftime('%a %b %-d  %H:%M') })
  table.insert(cells, { Text = '  ' })

  window:set_right_status(wezterm.format(cells))
end)

-- ────────────────────────────────────────────────────────────────────────────
-- Keybindings — macOS-friendly Cmd shortcuts
-- ────────────────────────────────────────────────────────────────────────────
config.keys = {
  -- Splits (iTerm-style)
  { key = 'd', mods = 'CMD',       action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- Pane navigation
  { key = 'LeftArrow',  mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Left'  },
  { key = 'RightArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Up'    },
  { key = 'DownArrow',  mods = 'CMD|OPT', action = act.ActivatePaneDirection 'Down'  },
  { key = '[',          mods = 'CMD',     action = act.ActivatePaneDirection 'Prev'  },
  { key = ']',          mods = 'CMD',     action = act.ActivatePaneDirection 'Next'  },

  -- Pane lifecycle
  { key = 'w',     mods = 'CMD',       action = act.CloseCurrentPane { confirm = false } },
  { key = 'Enter', mods = 'CMD',       action = act.TogglePaneZoomState },

  -- Tabs
  { key = 't',     mods = 'CMD',       action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'Tab',   mods = 'CTRL',      action = act.ActivateTabRelative(1)  },
  { key = 'Tab',   mods = 'CTRL|SHIFT',action = act.ActivateTabRelative(-1) },

  -- Clear scrollback like iTerm/Terminal.app
  { key = 'k', mods = 'CMD', action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
  } },

  -- Quick font size reset
  { key = '0', mods = 'CMD', action = act.ResetFontSize },

  -- Command palette
  { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
}

return config
