# Managed by Home Manager — deployed as ~/.zshrc for the `sravana` user
# (see modules/home/sravana.nix). Unlike jitendra's config this is a plain store
# copy, not an out-of-store symlink, because jitendra's clone is mode 0700 and
# therefore unreadable by other users. Edit it here and rebuild to apply.
#
# The NixOS system shell (/etc/zshrc) is still provided by programs.zsh in
# modules/system/nixos.nix.

# OpenCode CLI. Installed per user, e.g.:
#   curl -fsSL https://opencode.ai/v2/install | bash
export PATH="$HOME/.opencode/bin:$PATH"

# Use the kickstart.nvim config by default (the same appname jitendra uses):
# plain `nvim` then reads ~/.config/nvim-kickstart instead of ~/.config/nvim.
export NVIM_APPNAME=nvim-kickstart

# ---------------------------------------------------------------------------
# OpenCode — pinned server port
# ---------------------------------------------------------------------------
# OpenCode's background server uses a fixed default port (49374) shared by
# every user on the machine, so jitendra's instance and this one can't both run
# on it. Pin sravana's server to 49400 (jitendra uses 49401 in
# config/zsh/.zshrc) so both can run side by side.
#
# The port lives in ~/.config/opencode/service.json, so after the first run it
# stays put; the check only re-applies it if it ever drifts.
opencode() {
  [[ "$(command opencode service get port 2>/dev/null)" == 49400 ]] \
    || command opencode service set port 49400 >/dev/null 2>&1
  command opencode "$@"
}
