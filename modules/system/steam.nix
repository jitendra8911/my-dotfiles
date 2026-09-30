# Steam + 32-bit graphics.
#
# Kept in its own module (instead of the `/etc/nixos/configuration.nix` shim)
# so the shim stays free of host settings. Originally added by
# install-steam-nixos.sh.
{ ... }:

{
  # Needed by the Steam runtime / 32-bit games.
  hardware.graphics.enable32Bit = true;

  # Controllers (Steam Controller, Xbox pads, ...).
  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
