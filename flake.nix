{
  description = "Jitendra's dotfiles — declarative via Nix flakes + Home Manager (NixOS & nix-darwin)";

  inputs = {
    # Pin everything to the same release so nixpkgs/home-manager/nix-darwin agree.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

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
      home-manager,
      nix-darwin,
      ...
    }:
    let
      username = "jitendra";

      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
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
          { home-manager = homeManagerShared; }
        ];
      };

      darwinModules.mac = {
        imports = [
          ./modules/system/darwin.nix
          home-manager.darwinModules.home-manager
          { home-manager = homeManagerShared; }
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
