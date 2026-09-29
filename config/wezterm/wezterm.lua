-- WezTerm config — managed by Home Manager.
-- Symlinked to ~/.config/wezterm/wezterm.lua from <repo>/config/wezterm/.
-- Edit here; WezTerm auto-reloads on save, no rebuild needed.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Why this is here:
-- WezTerm was running as a *native Wayland* client. On Wayland there are no
-- server-side decorations and WezTerm draws none itself, so the window had no
-- title bar: no close button and no double-click-to-maximize.
--
-- Forcing the X11/XWayland backend gives it a normal GNOME title bar back
-- (close + minimise + maximise buttons, and double-click-the-title-bar works).
config.enable_wayland = false

-- Prefer the Wayland backend later? Comment out `enable_wayland = false` above
-- and uncomment these instead to put window buttons in WezTerm's own tab bar:
-- config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
-- config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }

config.keys = {
  -- Fullscreen stays available on a key as well.
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },
}

return config
