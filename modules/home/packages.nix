{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # --- Neovim / kickstart.nvim toolchain ---
    neovim
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
    tmux
    fzf
    bat
    eza
    zoxide
    starship
    jq
    yq-go
    tree
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    # Wayland desktop bits used by the Hyprland config (Linux only).
    wezterm
    fuzzel
    wl-clipboard
    grim
    slurp
  ];
}
