# Home Manager profile for the second NixOS user (`sravana`).
#
# Deliberately separate from ./default.nix (jitendra's profile): that one
# deploys the hyprland/tmux/wezterm/nvim dotfiles by symlinking them out of
# jitendra's clone at /home/jitendra, which is mode 0700 and therefore not
# readable by other users. So this profile only installs packages — the same
# set that used to live in `environment.systemPackages` — and leaves the
# dotfiles alone.
#
# Wired up in flake.nix (nixosModules.nixos) so it only exists on NixOS.
{ pkgs, ... }:
{
  home.username = "sravana";
  home.homeDirectory = "/home/sravana";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Moved out of modules/system/nixos.nix (environment.systemPackages) so
    # they live in each user's profile instead of system-wide.
    vim
    git
    curl
    wget
    openrgb
  ];
}
