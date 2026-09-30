# Hyprland is the Linux tiling WM (the Linux counterpart of AeroSpace on macOS).
# The system side is enabled in modules/system/nixos.nix; here we only deploy the
# user config. Guarded to Linux so a macOS evaluation never tries to link it.
{ config, lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/hypr";

  # Cursor theme for the Linux session: Adwaita — the ordinary arrow GNOME
  # already uses — instead of Hyprland's built-in fallback, which draws an odd
  # "water drop" arrow. This sets XCURSOR_THEME / HYPRCURSOR_THEME and points
  # GTK apps at the same theme. The Hyprland config repeats the values with
  # `env =` so the compositor picks them up however the session was started.
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };
  gtk.enable = true;
}
