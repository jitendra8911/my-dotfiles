# macOS host (nix-darwin).
#
# AeroSpace is installed with Homebrew, not Nix — Home Manager only symlinks
# config/aerospace into ~/.config/aerospace:
#   brew install --cask nikitabobko/tap/aerospace
{ pkgs, lib, ... }:

{
  # nix-darwin state version — do not bump casually.
  system.stateVersion = 6;

  # macOS account that Home Manager manages.
  system.primaryUser = "jitendra";
  users.users.jitendra = {
    name = "jitendra";
    home = "/Users/jitendra";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Keep the Homebrew that installs AeroSpace itself under the user's control.
  # (nix-darwin can manage Homebrew declaratively — enable this later if you want.)
  homebrew.enable = lib.mkDefault false;
}
