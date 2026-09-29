# Hyprland is the Linux tiling WM (the Linux counterpart of AeroSpace on macOS).
# The system side is enabled in modules/system/nixos.nix; here we only deploy the
# user config. Guarded to Linux so a macOS evaluation never tries to link it.
{ config, lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/hypr";
}
