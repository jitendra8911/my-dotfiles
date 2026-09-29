-- WezTerm config — managed by Home Manager.
-- Symlinked to ~/.config/wezterm/wezterm.lua from <repo>/config/wezterm/.
-- Edit here; WezTerm auto-reloads on save, no rebuild needed.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Backend: keep WezTerm on X11/XWayland (it defaults to native Wayland here).
-- The window itself is borderless and draws its own buttons — see the look &
-- feel section below — so the backend only affects rendering. Remove this line
-- to go back to native Wayland.
config.enable_wayland = false

-- Theme: match the Neovim colourscheme (catppuccin-mocha, see
-- config/nvim-kickstart/lua/custom/plugins/catppuccin.lua).
config.color_scheme = 'Catppuccin Mocha'

-- Borderless look: drop the GTK title bar (it follows the light GTK theme and
-- clashes with the terminal) and draw minimise/maximise/close in WezTerm's own
-- tab bar, which uses the palette below.
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }

-- Catppuccin Mocha window frame (the fancy tab bar + window buttons).
config.window_frame = {
  active_titlebar_bg = '#1e1e2e',   -- base
  inactive_titlebar_bg = '#181825', -- mantle
  button_fg = '#cdd6f4',            -- text
  button_bg = '#1e1e2e',            -- base
  button_hover_fg = '#1e1e2e',      -- base
  button_hover_bg = '#cba6f7',      -- mauve
}

-- Catppuccin Mocha tab bar (used by the retro tab bar / as a base).
config.colors = {
  tab_bar = {
    background = '#181825',                                                            -- mantle
    active_tab = { bg_color = '#1e1e2e', fg_color = '#cba6f7', intensity = 'Bold' },   -- base / mauve
    inactive_tab = { bg_color = '#181825', fg_color = '#a6adc8' },                     -- mantle / subtext0
    inactive_tab_hover = { bg_color = '#313244', fg_color = '#cdd6f4' },               -- surface0 / text
    new_tab = { bg_color = '#181825', fg_color = '#a6adc8' },
    new_tab_hover = { bg_color = '#313244', fg_color = '#cdd6f4' },
  },
}

-- Optional: translucent background, like Neovim's transparent floating windows.
-- config.window_background_opacity = 0.95

config.keys = {
  -- Fullscreen stays available on a key as well.
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },
}

return config
