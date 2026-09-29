# Managed by Home Manager — this file is symlinked to ~/.zshrc from
# <repo>/config/zsh/.zshrc (see modules/home/zsh.nix).
# Edit here; changes take effect in the next shell, no rebuild needed.

# OpenCode CLI
export PATH="$HOME/.opencode/bin:$PATH"

# ---------------------------------------------------------------------------
# NixOS rebuild shortcuts
# ---------------------------------------------------------------------------
# Plain rebuild. Works because /etc/nixos/configuration.nix is the shim that
# pulls the flake in from this repo.
alias switch='sudo nixos-rebuild switch'

# Explicit/pinned flake rebuild. `path:` is required so the git-ignored
# nixos/hardware-configuration.nix is visible to the evaluation.
alias switch-flake='sudo nixos-rebuild switch --flake "path:$HOME/projects/my-dotfiles#nixos"'
