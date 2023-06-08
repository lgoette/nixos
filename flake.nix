{
  description = "A very basic flake";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    mayniklas = {
      url = "github:mayniklas/nixos";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-utils.follows = "flake-utils";
        nixos-hardware.follows = "nixos-hardware";
      };
    };

  };

  outputs = { self, ... }@inputs:
    with inputs;
    {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlays.default = final: prev: (import ./overlays inputs) final prev;

      pi = {
        pi4b = { config, pkgs, lib, ... }: {
          imports = [
            # https://github.com/NixOS/nixos-hardware/tree/master/raspberry-pi/4
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
          networking = {
            wireguard.interfaces = {
              wg0 = {
                privateKeyFile = toString /var/src/secrets/wireguard/private;
                generatePrivateKeyFile = true;
              };
            };
          };
          hardware = { raspberry-pi."4".poe-hat.enable = true; };
          # Assuming this is installed on top of the disk image.
          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
              options = [ "noatime" ];
            };
          };
        };
      };

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs
        (map
          (x: {
            name = x;
            value = import (./modules + "/${x}");
          })
          (builtins.attrNames (builtins.readDir ./modules)))

      //

      {

        home-manager = { pkgs, ... }: {
          imports =
            [ ./home-manager/home.nix ./home-manager/home-desktop.nix ];
        };

      } // {

        # lgoette.mayniklas
        # -> imports used flake inputs
        # -> this way, they can easily be imported to different flake outputs
        mayniklas = { ... }: {
          imports = [
            # https://github.com/MayNiklas/nixos/tree/main/modules
            mayniklas.nixosModules.cloud-provider
            mayniklas.nixosModules.docker
            mayniklas.nixosModules.home-manager
            mayniklas.nixosModules.iperf
            mayniklas.nixosModules.locale
            mayniklas.nixosModules.minecraft
            mayniklas.nixosModules.monitoring
            mayniklas.nixosModules.nix-common
            mayniklas.nixosModules.openssh
            mayniklas.nixosModules.options
            mayniklas.nixosModules.sound
            mayniklas.nixosModules.user
            mayniklas.nixosModules.zsh
          ];
        };

      };

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs
        (map
          (x: {
            name = x;
            value = nixpkgs.lib.nixosSystem {

              # Make inputs and the flake itself accessible as module parameters.
              # Technically, adding the inputs is redundant as they can be also
              # accessed with flake-self.inputs.X, but adding them individually
              # allows to only pass what is needed to each module.
              specialArgs = { flake-self = self; } // inputs;

              system = "x86_64-linux";

              modules = [

                (./machines/x86_64-linux + "/${x}/configuration.nix")
                { imports = builtins.attrValues self.nixosModules; }
                { nixpkgs.overlays = [ self.overlays.default mayniklas.overlays.mayniklas ]; }

              ];
            };
          })
          (builtins.attrNames (builtins.readDir ./machines/x86_64-linux)))

      //

      builtins.listToAttrs (map
        (x: {
          name = x;
          value = nixpkgs.lib.nixosSystem {

            # Make inputs and the flake itself accessible as module parameters.
            # Technically, adding the inputs is redundant as they can be also
            # accessed with flake-self.inputs.X, but adding them individually
            # allows to only pass what is needed to each module.
            specialArgs = { flake-self = self; } // inputs;

            system = "aarch64-linux";

            modules = [
              self.pi.pi4b
              (./machines/aarch64-linux + "/${x}/configuration.nix")
              { imports = builtins.attrValues self.nixosModules; }
              { nixpkgs.overlays = [ self.overlays.default mayniklas.overlays.mayniklas ]; }

            ];
          };
        })
        (builtins.attrNames (builtins.readDir ./machines/aarch64-linux)))

      //

      {
        pi4b-image = nixpkgs.lib.nixosSystem rec {
          specialArgs = { flake-self = self; } // inputs;
          system = "aarch64-linux";
          modules = [
            ./images/pi4b/configuration.nix
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            { imports = builtins.attrValues self.nixosModules; }
            {
              nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
              nix.registry.nixpkgs.flake = nixpkgs;
              sdImage.compressImage = false;
              sdImage.imageBaseName = "pi4b-image";

            }
          ];
        };
      };

    }

    //

    (flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ]) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default mayniklas.overlays.mayniklas ];
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
          };
        };
      in
      rec {

        # Use nixpkgs-fmt for `nix fmt'
        formatter = pkgs.nixpkgs-fmt;

        # Custom packages added via the overlay are selectively exposed here, to
        # allow using them from other flakes that import this one.

        packages = flake-utils.lib.flattenTree {
          bukkit-spigot = pkgs.bukkit-spigot;
          minecraft-backup = pkgs.minecraft-backup;
          minecraft-controller = pkgs.minecraft-controller;

          # Generate a sd-card image for the pi
          # nix build '.#pi4b-image'
          pi4b-image =
            self.nixosConfigurations.pi4b-image.config.system.build.sdImage;

        };

        apps = {
          # Allow custom packages to be run using `nix run`
          bukkit-spigot =
            flake-utils.lib.mkApp { drv = packages.bukkit-spigot; };
          minecraft-backup =
            flake-utils.lib.mkApp { drv = packages.minecraft-backup; };
          minecraft-controller =
            flake-utils.lib.mkApp { drv = packages.minecraft-controller; };
        };
      });
}
