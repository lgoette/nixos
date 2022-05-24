{ pkgs, lib, mayniklas, home-manager, ... }:

{
  imports = [
    ../../../users/lasse.nix
    ../../../users/root.nix
    # home-manager.nixosModules.home-manager
  ];

  lgoette = { user.lasse.home-manager.enable = true; };

  mayniklas = {
    var.mainUser = "lasse";
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
    passwordAuthentication = false;
    startWhenNeeded = true;
    kbdInteractiveAuthentication = false;
    listenAddresses = [{
      addr = "0.0.0.0";
      port = 50937;
    }];
  };

  networking = { hostName = "lamabasis"; };

  home-manager.users.lasse.home.packages =
    with mayniklas.packages.x86_64-linux; [
      drone-gen
      vs-fix
    ];

  environment.systemPackages = with pkgs; [ bash-completion git nixfmt wget ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" "vc4" ];

    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };
  };

  hardware.deviceTree.filter = "bcm2711-rpi-*.dtb";

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  system.stateVersion = "22.05";

}
