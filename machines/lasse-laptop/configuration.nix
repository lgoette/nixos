{ self, ... }:
{ pkgs, lib, mayniklas, flake-self, ... }:

{
  imports = [
    ../../users/lasse.nix
    ../../users/root.nix
    # home-manager.nixosModules.home-manager
  ];

  lgoette = {
    grub.enable = true;
    kde.enable = true;
    bluetooth.enable = true;
    # user.lasse.home-manager.desktop = true; # Old home-manager configuration variant
  };

  mayniklas = {
    var.mainUser = "lasse";
    locale.enable = true;
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    zsh.enable = true;
  };

  # Home Manager configuration
  home-manager = {
    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.useUserPackages = true;

    extraSpecialArgs = {
      # Pass all flake inputs to home-manager modules aswell so we can use them
      # there.
      inherit flake-self;
      # Pass system configuration (top-level "config") to home-manager modules,
      # so we can access it's values for conditional statements
      system-config = config;
    };

    users.lasse = flake-self.homeConfigurations.desktop;
  };

  networking = {
    hostName = "Lasse-Laptop";
    firewall = { enable = true; };
    # Enable networkmanager
    networkmanager.enable = true;
  };
  users.extraUsers.lasse.extraGroups = [ "networkmanager" ];

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
    ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "22.05";

}
