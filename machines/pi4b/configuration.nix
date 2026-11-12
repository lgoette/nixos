{
  config,
  pkgs,
  lib,
  nixpkgs,
  nixos-hardware,
  ...
}:
{

  ### building the image
  # nix build .#nixosConfigurations.pi4b.config.system.build.sdImage

  # this workaround is currently needed to build the sd-image
  # basically: there currently is an issue that prevents the sd-image to be built successfully
  # remove this once the issue is fixed!
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  # Remove when the Pi kernel includes upstream commit 10a47fb67340.
  # Older kernel tools lack __u128, which newer ARM64 system headers require.
  # nixos-hardware ignores boot.kernelPatches for the Pi kernel, so patch it directly.
  boot.kernelPackages = pkgs.linuxPackagesFor (
    (pkgs.callPackage "${nixos-hardware}/raspberry-pi/common/kernel.nix" { rpiVersion = 4; })
    .overrideAttrs
      (old: {
        patches = old.patches ++ [
          (pkgs.fetchurl {
            url = "https://github.com/torvalds/linux/commit/10a47fb67340.patch";
            hash = "sha256-MLRaNOAprujNVxIzAKg6sd/kc8tsiNh60bPMzYkeBkg=";
          })
        ];
      })
  );

  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  nix.registry.nixpkgs.flake = nixpkgs;
  sdImage.compressImage = false;
  image.baseName = "pi4b-image";
  ###

  imports = [
    ../../users/lasse.nix
    ../../users/root.nix

    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

  mayniklas = {
    locale.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    zsh.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    bash-completion
    git
    wget
  ];

  networking = {
    hostName = "pi4b";
    interfaces.eth0 = {
      useDHCP = true;
    };
  };

  clan.core.deployment.requireExplicitUpdate = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "22.05";

}
