# Deploys ~/.config/wezterm as an out-of-store symlink to config/wezterm, the
# same pattern used for nvim/tmux/hypr. The wezterm package itself is installed
# from modules/home/packages.nix (Linux).
{ config, ... }:
{
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/wezterm";
}
