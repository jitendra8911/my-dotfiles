{
  description = "Jitendra's dotfiles — declarative via Nix flakes + Home Manager (NixOS & nix-darwin)";

  inputs = {
    # Stable base for the whole system.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Used only to pull specific packages that are ahead in unstable
    # (currently Neovim: 0.12.5 vs 0.12.4 in 26.05). See `neovimOverlay`.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      username = "jitendra";

      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      # Stay on stable 26.05, but take Neovim from nixos-unstable so it is the
      # newer release. Add more attributes here if you want them from unstable.
      neovimOverlay = final: prev: {
        neovim = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.neovim;
      };

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ neovimOverlay ];
        };

      # Wiring shared by the NixOS and nix-darwin Home Manager instances.
      homeManagerShared = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = { inherit self; };
        users.${username} = import ./modules/home;
      };
    in
    {
      # ---- Reusable host modules ------------------------------------------
      # Self-contained (system settings *and* Home Manager). `/etc/nixos/
      # configuration.nix` imports these, so it no longer hardcodes anything.
      nixosModules.nixos = {
        imports = [
          ./modules/system/nixos.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ neovimOverlay ];
            # jitendra's profile comes from homeManagerShared; the second user
            # is added here rather than in homeManagerShared so the macOS host
            # (which has no `sravana` account) is unaffected. Merge the `users`
            # attrs (not the whole set) so jitendra's entry is kept.
            home-manager = homeManagerShared // {
              users = homeManagerShared.users // {
                sravana = import ./modules/home/sravana.nix;
              };
            };
          }
        ];
      };

      darwinModules.mac = {
        imports = [
          ./modules/system/darwin.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ neovimOverlay ];
            home-manager = homeManagerShared;
          }
        ];
      };

      # ---- NixOS desktop (Hyprland) --------------------------------------
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit self; };
        modules = [ self.nixosModules.nixos ];
      };

      # ---- macOS laptop (AeroSpace) --------------------------------------
      # Rename "mac" to whatever you like, then:  nh darwin switch . -H mac
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = { inherit self; };
        modules = [ self.darwinModules.mac ];
      };

      # ---- Standalone Home Manager (works with no system rebuild) ---------
      #   home-manager switch --flake .#jitendra@nixos
      homeConfigurations."${username}@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor linuxSystem;
        extraSpecialArgs = { inherit self; };
        modules = [ ./modules/home ];
      };
    };
}
