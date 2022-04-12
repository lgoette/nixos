{
  description = "A very basic flake";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    mayniklas.url = "github:mayniklas/nixos";
    mayniklas.inputs.nixpkgs.follows = "nixpkgs";
    mayniklas.inputs.home-manager.follows = "home-manager";
    mayniklas.inputs.flake-utils.follows = "flake-utils";

  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      # Function to create defult (common) system config options
      defFlakeSystem = systemArch: baseCfg:
        nixpkgs.lib.nixosSystem {

          system = "${systemArch}";
          modules = [

            # Make inputs and overlay accessible as module parameters
            { _module.args.inputs = inputs; }
            {
              _module.args.self-overlay = self.overlay;
            }

            # Add home-manager option to all configs
            ({ ... }: {
              imports = builtins.attrValues self.nixosModules
                ++ builtins.attrValues mayniklas.nixosModules ++ [
                  { # Set the $NIX_PATH entry for nixpkgs. This is necessary in
                    # this setup with flakes, otherwise commands like `nix-shell
                    # -p pkgs.htop` will keep using an old version of nixpkgs.
                    # With this entry in $NIX_PATH it is possible (and
                    # recommended) to remove the `nixos` channel for both users
                    # and root e.g. `nix-channel --remove nixos`. `nix-channel
                    # --list` should be empty for all users afterwards
                    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                    nixpkgs.overlays = [ self.overlay ];
                  }
                  baseCfg
                  home-manager.nixosModules.home-manager
                  # DONT set useGlobalPackages! It's not necessary in newer
                  # home-manager versions and does not work with configs using
                  # `nixpkgs.config`
                  { home-manager.useUserPackages = true; }
                ];
              # Let 'nixos-version --json' know the Git revision of this flake.
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;
              nix.registry.nixpkgs.flake = nixpkgs;
            })
          ];
        };

    in {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      overlay = final: prev: (import ./overlays) final prev;

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs (map (x: {
        name = x;
        value = import (./modules + "/${x}");
      }) (builtins.attrNames (builtins.readDir ./modules)));

      # Each subdirectory in ./machins is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (map (x: {
        name = x;
        value = defFlakeSystem "x86_64-linux" {
          imports = [
            (import (./machines + "/${x}/configuration.nix") { inherit self; })
          ];
        };
      }) (builtins.attrNames (builtins.readDir ./machines)));
    } //

    (flake-utils.lib.eachSystem [ "x86_64-linux" ]) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
          };
        };
      in rec {

        packages = flake-utils.lib.flattenTree {
          bukkit-spigot = pkgs.bukkit-spigot;
          minecraft-controller = pkgs.minecraft-controller;
        };

        apps = {
          # Allow custom packages to be run using `nix run`
          bukkit-spigot =
            flake-utils.lib.mkApp { drv = packages.bukkit-spigot; };
          minecraft-controller =
            flake-utils.lib.mkApp { drv = packages.minecraft-controller; };
        };
      });
}
