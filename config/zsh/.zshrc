# Managed by Home Manager — this file is symlinked to ~/.zshrc from
# <repo>/config/zsh/.zshrc (see modules/home/zsh.nix).
# Edit here; changes take effect in the next shell, no rebuild needed.

# OpenCode CLI
export PATH="$HOME/.opencode/bin:$PATH"

# ---------------------------------------------------------------------------
# OpenCode — pinned server port
# ---------------------------------------------------------------------------
# OpenCode starts a background server on a fixed default port (49374) shared by
# every user on the machine, so a second instance can't start while the first
# is running. Pin this user's server to 49401 so it never collides with
# sravana's instance (pinned to 49400 in config/zsh/sravana.zshrc).
#
# The port lives in ~/.config/opencode/service.json, so after the first run it
# stays put; the check only re-applies it if it ever drifts.
opencode() {
  [[ "$(command opencode service get port 2>/dev/null)" == 49401 ]] \
    || command opencode service set port 49401 >/dev/null 2>&1
  command opencode "$@"
}

# Use the kickstart.nvim config by default. It lives in ~/.config/nvim-kickstart
# (plain `nvim` would look for ~/.config/nvim and start with no config at all).
nvim() { NVIM_APPNAME=nvim-kickstart command nvim "$@"; }

# ---------------------------------------------------------------------------
# NixOS rebuild shortcuts
# ---------------------------------------------------------------------------
# Plain rebuild. Works because /etc/nixos/configuration.nix is the shim that
# pulls the flake in from this repo.
alias switch='sudo nixos-rebuild switch'

# Explicit/pinned flake rebuild. `path:` is required so the git-ignored
# nixos/hardware-configuration.nix is visible to the evaluation.
alias switch-flake='sudo nixos-rebuild switch --flake "path:$HOME/projects/my-dotfiles#nixos"'
