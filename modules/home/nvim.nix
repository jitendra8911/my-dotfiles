# kickstart.nvim is deployed as an "out-of-store" symlink: ~/.config/nvim-kickstart
# points straight at <repo>/config/nvim-kickstart. That keeps it editable without a
# rebuild and lets lazy.nvim update `lazy-lock.json` in place.
#
# Run it with:   NVIM_APPNAME=nvim-kickstart nvim
# (or add that alias to your shell).
{ config, ... }:
{
  xdg.configFile."nvim-kickstart".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/nvim-kickstart";
}
