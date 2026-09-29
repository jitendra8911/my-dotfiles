# /etc/nixos/configuration.nix — thin shim.
#
# All real configuration now lives in my-dotfiles. This file no longer holds any
# host settings; it just pulls in the flake's `nixosModules.nixos` (system
# settings + Home Manager) so the plain rebuild command keeps working.
#
# Install it with:
#   sudo ~/projects/my-dotfiles/bins/link-nixos.sh
# (that script symlinks this file — and hardware-configuration.nix — into
#  /etc/nixos, backing up whatever it replaces)
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
