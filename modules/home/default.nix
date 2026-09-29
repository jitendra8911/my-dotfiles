{ config, lib, pkgs, ... }:
let
  # Where the account lives, per platform. Used as the default repo location
  # and as the Home Manager home directory.
  platformHome = if pkgs.stdenv.isDarwin then "/Users/jitendra" else "/home/jitendra";
in
{
  imports = [
    ./packages.nix
    ./git.nix
    ./nvim.nix
    ./tmux.nix
    ./hyprland.nix
    ./aerospace.nix
  ];

  options.dotfiles.repoPath = lib.mkOption {
    type = lib.types.str;
    default = "${platformHome}/projects/my-dotfiles";
    example = "/Users/jitendra/dev/my-dotfiles";
    description = ''
      Absolute path to your clone of this repository.

      Every file under {file}`config/` is symlinked *out of the Nix store* from
      here, so you keep editing the repo and see the change immediately — the
      same live-editing workflow as `stow`, except Home Manager owns the links.
      Override this per host if your clone lives somewhere else.
    '';
  };

  config = {
    home.username = lib.mkDefault "jitendra";
    home.homeDirectory = lib.mkDefault platformHome;
    home.stateVersion = "26.05";

    # Let Home Manager manage itself (needed for standalone use).
    programs.home-manager.enable = true;
  };
}
