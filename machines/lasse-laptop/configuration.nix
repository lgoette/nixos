{ pkgs, mayniklas, home-manager, ... }:

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

  networking = {
    hostName = "Lasse-Laptop";
    firewall = { enable = true; };
    # Enable networkmanager
    networkmanager.enable = true;
  };
  users.extraUsers.lasse.extraGroups = [ "networkmanager" ];

  environment.systemPackages = with pkgs; [ bash-completion git nixfmt wget ];

  home-manager.users = {
    lasse = {
      # packages from mayniklas
      home.packages = with mayniklas.packages.x86_64-linux; [
        drone-gen
        vs-fix
      ];
      imports = [ ../../home-manager/lasse-desktop.nix ];
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

}
