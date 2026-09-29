# my-dotfiles

Dotfiles managed declaratively with **Nix flakes + Home Manager**, targeting
**NixOS (Hyprland)** and **macOS / nix-darwin (AeroSpace)**.

No `stow` needed. Home Manager owns every symlink, and because they are
"out-of-store" links you still edit files in this repo and see the change
immediately — no rebuild required.

## Layout

```
my-dotfiles/
├── flake.nix                     # inputs + nixosConfigurations / darwinConfigurations / homeConfigurations
├── flake.lock
├── modules/
│   ├── home/                     # Home Manager (shared by both platforms)
│   │   ├── default.nix           #   imports features, declares dotfiles.repoPath
│   │   ├── packages.nix          #   CLI packages (neovim, tmux, ripgrep, …)
│   │   ├── git.nix               #   git identity + settings
│   │   ├── nvim.nix              #   -> ~/.config/nvim-kickstart
│   │   ├── tmux.nix              #   -> ~/.config/tmux/tmux.conf
│   │   ├── hyprland.nix          #   -> ~/.config/hypr          (Linux only)
│   │   └── aerospace.nix         #   -> ~/.config/aerospace     (macOS only)
│   └── system/
│       ├── nixos.nix             # NixOS host "nixos" (Hyprland, GNOME fallback, users, openrgb…)
│       └── darwin.nix            # macOS host "mac"
├── config/                       # the actual dotfiles (never edited in place by Nix)
│   ├── nvim-kickstart/           # kickstart.nvim
│   ├── tmux/tmux.conf
│   ├── hypr/hyprland.conf        # Linux tiling WM
│   └── aerospace/aerospace.toml  # macOS office-Mac tiling WM
└── nixos/
    ├── configuration.nix         # copy of the /etc/nixos shim
    ├── hardware-configuration.nix.example
    └── hardware-configuration.nix   # git-ignored, machine-specific
```

## How the symlinks work

Every file under `config/` is linked with Home Manager's
`mkOutOfStoreSymlink`, so e.g.

```
~/.config/nvim-kickstart  ->  <repo>/config/nvim-kickstart
~/.config/hypr            ->  <repo>/config/hypr
~/.config/aerospace       ->  <repo>/config/aerospace
~/.config/tmux/tmux.conf  ->  <repo>/config/tmux/tmux.conf
```

`dotfiles.repoPath` (default `~/projects/my-dotfiles`) is where Nix expects
the clone. Override it per host if yours lives elsewhere.

## Quick start — NixOS

```sh
# 1. one-time: give the flake access to your machine's hardware config
cp /etc/nixos/hardware-configuration.nix ~/projects/my-dotfiles/nixos/

# 2. use the shim so `nixos-rebuild switch` also comes from the repo
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
sudo cp ~/projects/my-dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix

# 3. build (path: is required so the git-ignored hardware config is included)
nh os switch path:. -H nixos
# or: sudo nixos-rebuild switch --flake path:$PWD#nixos
```

## Quick start — macOS

```sh
# AeroSpace itself is a Homebrew cask (Nix only manages its config):
brew install --cask nikitabobko/tap/aerospace

nh darwin switch . -H mac
```

## Home Manager without touching the system

```sh
home-manager switch --flake .#jitendra@nixos
```

## Day-to-day usage

- **Neovim** (kickstart.nvim) — run it via `NVIM_APPNAME`:
  ```sh
  alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
  ```
- **tmux** — plugins use TPM, which is not installed by Nix. Bootstrap once:
  ```sh
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ```
  then press `prefix + I` inside tmux.
- **Hyprland** — reload after editing `config/hypr/hyprland.conf` with
  `Alt+Shift+C` (or `hyprctl reload`). The mod key is `Alt`, matching the
  AeroSpace muscle memory; change `$mainMod` to `SUPER` if you prefer.

## Adding a new app to the setup

1. Put its config under `config/<app>/`.
2. Add a `modules/home/<app>.nix` that links it, e.g.
   ```nix
   { config, ... }:
   {
     xdg.configFile."<app>".source =
       config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/<app>";
   }
   ```
3. Import it from `modules/home/default.nix`.
4. Rebuild.

## Changing the repo path or host name

- Repo cloned elsewhere? Set `dotfiles.repoPath = "/your/path"` in the host
  module (e.g. `modules/system/nixos.nix`).
- Rename `darwinConfigurations."mac"` in `flake.nix` and rebuild with `-H <name>`.
