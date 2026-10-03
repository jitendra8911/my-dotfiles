# NixOS host: "nixos"
#
# This is the source of truth for the system. `/etc/nixos/configuration.nix`
# is reduced to a thin shim that imports this module, so nothing host-specific
# is hardcoded there any more.
#
# Rebuild with one of:
#   nh os switch path:. -H nixos
#   sudo nixos-rebuild switch --flake path:$PWD#nixos
#
# `path:` (instead of a plain `.`) is required so the git-ignored
# `nixos/hardware-configuration.nix` is visible to the pure flake evaluation.
{ config, lib, pkgs, ... }:

{
  imports = [
    # Machine-specific disk/CPU config. Copy it once:
    #   cp /etc/nixos/hardware-configuration.nix ~/projects/my-dotfiles/nixos/
    # It is intentionally git-ignored.
    ../../nixos/hardware-configuration.nix

    # Steam + 32-bit graphics.
    ./steam.nix
  ];

  # Do NOT bump this casually — see the comment in the NixOS manual.
  system.stateVersion = "26.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Store maintenance. Every switch creates a new generation, and generations
  # are GC roots, so old package versions stay pinned on disk forever unless
  # they are collected. auto-optimise-store hard-links identical files to
  # reclaim space now; the GC timer drops generations older than 14 days.
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ------------------------------- Boot -------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "i2c-dev" "i2c-i801" ];

  # ----------------------------- Networking ---------------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --------------------------- Locale / time --------------------------------
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ------------------------------- Fonts -------------------------------------
  # Nerd Fonts: wezterm, Hyprland bars and CLI tools (eza, starship, ...) use
  # glyphs from these; without them icons render as tofu boxes.
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
  ];

  # ------------------------------- Shell ------------------------------------
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # --------------------------- Desktops / WM --------------------------------
  # Hyprland: the Linux tiling WM (the counterpart of AeroSpace on macOS).
  # User config is deployed by Home Manager -> ~/.config/hypr.
  # withUWSM runs the session through the Universal Wayland Session Manager
  # (systemd-supervised) — the recommended, and much more reliable, way to
  # start Hyprland from a display manager. XWayland keeps X11 apps working.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # GNOME + i3 are kept as fallbacks / for the second user. Once you are happy
  # with Hyprland you can delete these four lines.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable GNOME's GCR SSH agent. It is pulled in automatically by
  # `services.gnome.gnome-keyring.enable` (which GNOME enables), and it is the
  # component behind the runaway-CPU bug: when SSH asks it to sign with a
  # passphrase-protected key it can't prompt for, it spawns `ssh-add`, which
  # busy-loops at ~100% CPU forever instead of failing. It also deadlocked
  # `git push` the same way. GitHub now authenticates with a dedicated
  # passphrase-less key via `~/.ssh/config` (`IdentityAgent none`), so no agent
  # is needed at all. See the README for the key setup.
  services.gnome.gcr-ssh-agent.enable = false;

  # i3 is an X11 window manager: enabling the session is not enough, X11
  # itself must be on. Without this there is no `Xorg` binary, so picking i3
  # at the login screen just produces a blank, unresponsive screen.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;

  # XDG desktop portals (needed by Hyprland and friends for file pickers,
  # screenshots, etc.). `programs.hyprland` wires its own portal; this makes
  # sure the portal machinery itself is on.
  xdg.portal.enable = true;

  # ------------------------------ Sound -------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ---------------------------- Peripherals ---------------------------------
  services.printing.enable = true;
  # Bluetooth (input devices, audio). No GUI applet — GNOME ships one.
  hardware.bluetooth.enable = true;
  # I2C bus for DDC/CI monitor control (ddcutil) alongside the OpenRGB SMBus
  # use of /dev/i2c below.
  hardware.i2c.enable = true;
  programs.nix-ld.enable = true;
  # Prebuilt binaries (e.g. the OpenCode TUI) run through nix-ld. Its native
  # Wayland clipboard does dlopen("libwayland-client.so.0"), which fails unless
  # the library is on nix-ld's search path — without this, copy silently falls
  # back to OSC 52 and terminals like GNOME Console ignore it.
  programs.nix-ld.libraries = with pkgs; [ wayland ];
  programs.firefox.enable = true;
  environment.pathsToLink = [ "/libexec" ];

  # OpenRGB lighting (motherboard SMBus + profile service per user).
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };

  systemd.user.services.openrgb-profile-jitendra = {
    description = "Apply OpenRGB lighting profile for jitendra";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionUser = "jitendra";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --profile Jitendra.orp";
    };
  };

  systemd.user.services.openrgb-profile-sravana = {
    description = "Apply OpenRGB lighting profile for sravana";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    unitConfig.ConditionUser = "sravana";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --profile Sravani.orp";
    };
  };

  # ------------------------------- Users ------------------------------------
  users.users.jitendra = {
    isNormalUser = true;
    description = "Jitendra Malakalapalli";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  users.users.sravana = {
    isNormalUser = true;
    description = "Sravana Vaidehi Challagulla";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  # ---------------------------- Packages ------------------------------------
  # Installed per user via Home Manager instead of system-wide:
  #   - jitendra: modules/home/packages.nix
  #   - sravana:  modules/home/sravana.nix
  # (environment.systemPackages would make them available to every user and
  # root; the Home Manager profiles scope them to the user who needs them.)
}
