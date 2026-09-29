# AeroSpace is the macOS tiling WM (kept for the office Mac). It is installed with
# Homebrew, not Nix — so all we do here is deploy the config on macOS only:
#   brew install --cask nikitabobko/tap/aerospace
{ config, lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.isDarwin {
  xdg.configFile."aerospace".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/aerospace";
}
