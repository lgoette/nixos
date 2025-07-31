{ self, ... }:
{ pkgs, config, lib, mayniklas, flake-self, ... }:

{
  imports = [
    ../../users/lasse.nix
    ../../users/root.nix
    # ./wg0.nix
  ];

  lgoette = {
    # grub.enable = true; # TODO: Zu grub wechseln
    kde.enable = true;
    bluetooth.enable = true;
    sound.enable = true;
    locale.enable = true;
  };

  mayniklas = {
    var.mainUser = "lasse";
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
    useUserPackages = true;
    backupFileExtension = "hm-backup";

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

  # Enable tailscale vpn
  # Start with `tailscale up --login-server=https://tailscale.lasse-goette.de/`
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--login-server=https://tailscale.lasse-goette.de/"
    ];
    extraSetFlags = [
      "--operator=lasse"
    ];
  };

  networking = {
    hostName = "Lasse-Laptop";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5173 ];
    };
    # Enable networkmanager
    networkmanager.enable = true;
  };
  users.extraUsers.lasse.extraGroups = [
    "networkmanager"
    "audio"
  ]; # TODO: move audio group to sound module - find variant for generic user

  # Enable autostart
  # xdg.autostart.enable = true; # TODO: Packages can start on startup not working

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      psmisc
      bash-completion
      git
      nixfmt
      wget

      # For sddm Theme
      # libsForQt5.qt5.qtquickcontrols2
      # libsForQt5.qt5.qtgraphicaleffects
    ];

  # Enable pcscd for yubikey support
  services.pcscd.enable = true;

  # Trackpad, Trackpoint and mouse options
  services.xserver.libinput.enable = true;

  # fileSystems."/" = {
  #  device = "/dev/disk/by-label/nixos";
  #   autoResize = true;
  #   fsType = "ext4";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-label/ESP";
  #   fsType = "vfat";
  # };

  boot = {
    loader.systemd-boot.enable =
      true; # TODO: Zu grub wechseln; nur die letzten 3 nix configs in boot speichern
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules =
      [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "ntfs" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # allows building ARM stuff
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1c9abb53-60f6-46b3-80b9-da0231a48c2e";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-2e1a9d9e-62ac-4b6d-8421-db15361e4fc5".device =
    "/dev/disk/by-uuid/2e1a9d9e-62ac-4b6d-8421-db15361e4fc5";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5EB5-75E2";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Automatic garbage collection
  nix.settings.auto-optimise-store = true;
  nix.gc = lib.mkForce {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = config.nixpkgs.config.allowUnfree;

  system.stateVersion = "22.05";
}
