# Deploys tmux.conf to the path tmux actually reads: ~/.config/tmux/tmux.conf
# (the old stow layout placed it at ~/.config/tmux/.tmux.conf, which tmux
# ignores).
#
# The plugins are the nixpkgs-packaged tmux plugins (pkgs.tmuxPlugins) rather
# than TPM: no ~/.tmux/plugins clone, nothing to run `prefix + I` for, and no
# network at runtime. Each plugin ships a `.tmux` shell script; plugins.conf —
# generated below from each package's `rtp` (runtime path) — loads them with
# `run-shell`, and the repo's tmux.conf pulls that file in with `source-file`.
{ config, lib, pkgs, ... }:
let
  # Same set the old TPM config listed. Add or remove plugins here; the paths
  # are resolved from the nix store so they stay correct across rebuilds.
  plugins = with pkgs.tmuxPlugins; [
    sensible
    resurrect
    catppuccin
  ];
in
{
  # Live-editable main config: the repo stays the source of truth.
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/tmux/tmux.conf";

  # Generated plugin loader, kept in its own file so tmux.conf can stay an
  # out-of-store symlink. tmux.conf sources this *after* it sets the
  # @catppuccin_* options, which the catppuccin plugin reads when it loads.
  xdg.configFile."tmux/plugins.conf".text =
    lib.concatMapStrings (p: "run-shell ${p.rtp}\n") plugins;
}
