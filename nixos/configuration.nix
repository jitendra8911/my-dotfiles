# /etc/nixos/configuration.nix — thin shim.
#
# All real configuration now lives in my-dotfiles. This file no longer holds any
# host settings; it just pulls in the flake's `nixosModules.nixos` (system
# settings + Home Manager) so the plain rebuild command keeps working.
#
# Install it with:
#   sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
#   sudo cp ~/projects/my-dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix
#
# Rebuild (either works — the flake form is preferred):
#   nh os switch path:/home/jitendra/projects/my-dotfiles -H nixos
#   sudo nixos-rebuild switch
#
# `path:` matters: it makes Nix copy the working tree as-is, so the git-ignored
# nixos/hardware-configuration.nix is visible to the pure evaluation.
{ ... }:
let
  dotfiles = "/home/jitendra/projects/my-dotfiles";
in
{
  imports = [
    (builtins.getFlake "path:${dotfiles}").nixosModules.nixos
  ];
}
