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
├── bins/
│   ├── link-nixos.sh             # symlinks nixos/ into /etc/nixos (run with sudo)
│   └── tmux-sessionizer          # `prefix + f` project picker (see Day-to-day usage)
└── nixos/
    ├── configuration.nix         # symlinked to /etc/nixos/configuration.nix
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
# 1. Symlink this repo's config into /etc/nixos. This adopts the machine's
#    hardware-configuration.nix into the repo and backs up (as *.bak) any file
#    it replaces, so it is safe to re-run.
sudo ~/projects/my-dotfiles/bins/link-nixos.sh

# 2. build (`path:` is required so the git-ignored hardware config is included)
nh os switch path:. -H nixos
# or, now that /etc/nixos points here: sudo nixos-rebuild switch
```

`/etc/nixos` ends up as symlinks back into this checkout, so there is a single
source of truth:

```
/etc/nixos/configuration.nix          -> <repo>/nixos/configuration.nix
/etc/nixos/hardware-configuration.nix -> <repo>/nixos/hardware-configuration.nix
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
  then press `prefix + I` inside tmux. Press `prefix + f` to fuzzy-find a
  project under `~/projects` and open its tmux session, reusing it if it already
  exists. That picker is `bins/tmux-sessionizer`; change the roots it searches
  or how deep it looks via `PROJECT_ROOTS` / `TMUX_SESSIONIZER_DEPTH` at the top
  of the script.
- **Hyprland** — reload after editing `config/hypr/hyprland.conf` with
  `Super+Shift+C` (or `hyprctl reload`). The mod key is `Super` (the Windows/
  Command key), the usual Hyprland default; change `$mainMod` to `ALT` if you
  prefer the AeroSpace-style bindings.

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
