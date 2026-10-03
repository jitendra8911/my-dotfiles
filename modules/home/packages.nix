{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # --- Neovim / kickstart.nvim toolchain ---
    neovim
    # node + npm: Mason installs npm-distributed language servers (e.g. vtsls)
    # by shelling out to `npm`, so without Node those installs fail.
    nodejs
    ripgrep
    fd
    lazygit
    gcc
    gnumake
    unzip
    curl
    wget
    git
    tree-sitter
    lua-language-server

    # --- Terminal & shell niceties ---
    vim
    tmux
    fzf
    bat
    eza
    zoxide
    starship
    jq
    yq-go
    tree

    # --- System monitoring ---
    btop
    htop
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    # Wayland desktop bits used by the Hyprland config (Linux only).
    wezterm
    fuzzel
    wl-clipboard
    grim
    slurp
    # RGB control (was in environment.systemPackages). The per-user systemd
    # profile services call it by store path, so they work regardless.
    openrgb
  ];
}
