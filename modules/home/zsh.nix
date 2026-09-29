# Deploys ~/.zshrc as an out-of-store symlink to config/zsh/.zshrc, matching
# the nvim/tmux/hypr setup: the file stays in the repo and is editable without
# a rebuild. The NixOS system shell (/etc/zshrc) is still provided by
# programs.zsh in modules/system/nixos.nix.
{ config, ... }:
{
  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/zsh/.zshrc";
}
