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
  ];

  # Do NOT bump this casually — see the comment in the NixOS manual.
  system.stateVersion = "26.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

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

  # ------------------------------- Shell ------------------------------------
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # --------------------------- Desktops / WM --------------------------------
  # Hyprland: the Linux tiling WM (the counterpart of AeroSpace on macOS).
  # User config is deployed by Home Manager -> ~/.config/hypr.
  programs.hyprland.enable = true;

  # GNOME + i3 are kept as fallbacks / for the second user. Once you are happy
  # with Hyprland you can delete these three lines.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.windowManager.i3.enable = true;

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
  programs.nix-ld.enable = true;
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
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    openrgb
  ];
}
