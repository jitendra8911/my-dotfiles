# Deploys tmux.conf to the path tmux actually reads: ~/.config/tmux/tmux.conf
# (the old stow layout placed it at ~/.config/tmux/.tmux.conf, which tmux ignores).
#
# TPM plugins still bootstrap once with:
#   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# then press prefix + I inside tmux.
{ config, ... }:
{
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/tmux/tmux.conf";
}
