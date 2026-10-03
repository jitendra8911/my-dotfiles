# Home Manager profile for the second NixOS user (`sravana`).
#
# Deliberately separate from ./default.nix (jitendra's profile): that one
# deploys the hyprland/tmux/wezterm/nvim dotfiles by symlinking them out of
# jitendra's clone at /home/jitendra, which is mode 0700 and therefore not
# readable by other users. So this profile installs exactly the same *packages*
# as jitendra (nvim, tmux, wezterm, … — imported from ./packages.nix) but leaves
# the dotfiles alone.
#
# Wired up in flake.nix (nixosModules.nixos) so it only exists on NixOS.
{ ... }:
{
  imports = [ ./packages.nix ];

  home.username = "sravana";
  home.homeDirectory = "/home/sravana";
  home.stateVersion = "26.05";

  # Sravana's own shell config. Deployed as a *store* copy (not the
  # out-of-store symlink jitendra's .zshrc uses): jitendra's clone is mode
  # 0700, so a symlink into it would be unreadable by this user. It sets up the
  # OpenCode CLI and pins her server to port 49400 so it can run alongside
  # jitendra's (49401).
  home.file.".zshrc".source = ../../config/zsh/sravana.zshrc;
}
