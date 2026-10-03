# OpenCode V2 terminal (CLI) settings.
#
# V2 keeps terminal/TUI settings — theme, keybinds, mouse, … — in
# ~/.config/opencode/cli.json, separate from the server/project config in
# opencode.json(c). This deploys that file as an out-of-store symlink so the
# repo copy stays live-editable, matching the tmux/wezterm/nvim setups.
#
# The theme itself is set in config/opencode/cli.json ("catppuccin", the
# built-in Mocha flavor — see https://opencode.ai/v2/docs/cli/theme).
#
# Note: the `opencode` binary is installed per user with the official installer
# (curl … | bash) rather than from nixpkgs, because nixpkgs and the Home Manager
# `programs.opencode` module still track OpenCode V1 (V1 puts terminal settings
# in tui.json and would additionally pull in an older opencode package).
{ config, ... }:
{
  xdg.configFile."opencode/cli.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/opencode/cli.json";
}
