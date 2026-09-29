#!/usr/bin/env bash
# Symlink this repo's NixOS config into /etc/nixos.
#
#   sudo ~/projects/my-dotfiles/bins/link-nixos.sh
#
# Creates:
#   /etc/nixos/configuration.nix          -> <repo>/nixos/configuration.nix
#   /etc/nixos/hardware-configuration.nix -> <repo>/nixos/hardware-configuration.nix
#
# Existing regular files are backed up once as <file>.bak, so the script is safe
# to re-run. If the repo has no hardware-configuration.nix yet, the system's is
# adopted into the repo first (it is git-ignored, so it never gets committed).

set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "error: run me with sudo (writing to /etc/nixos needs root)" >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd -- "$script_dir/.." && pwd)"

etc=/etc/nixos

# Replace $2 with a symlink to $1, backing up any existing regular file.
link() {
  local src="$1" dest="$2"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      echo "ok      $dest -> $src"
      return
    fi
    rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    if [[ ! -e "$dest.bak" ]]; then
      cp -a "$dest" "$dest.bak"
      echo "backup  $dest -> $dest.bak"
    fi
    rm -f "$dest"
  fi

  ln -s "$src" "$dest"
  echo "link    $dest -> $src"
}

# configuration.nix must exist in the repo.
link "$repo/nixos/configuration.nix" "$etc/configuration.nix"

# hardware-configuration.nix is machine-specific and git-ignored. If it is not
# in the repo yet, move the system's copy in and link back to it.
if [[ ! -e "$repo/nixos/hardware-configuration.nix" && -e "$etc/hardware-configuration.nix" ]]; then
  cp -a "$etc/hardware-configuration.nix" "$repo/nixos/hardware-configuration.nix"
  echo "adopted $etc/hardware-configuration.nix -> $repo/nixos/hardware-configuration.nix"
fi
link "$repo/nixos/hardware-configuration.nix" "$etc/hardware-configuration.nix"

echo
echo "Done."
echo "Rebuild with:"
echo "  nh os switch path:$repo -H nixos"
echo "  # or simply:  sudo nixos-rebuild switch"
