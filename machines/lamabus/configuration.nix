# nix run github:numtide/nixos-anywhere -- --flake .#lamabus root@192.168.0.23
# nix run .\#lollypops -- lamabus
{ self, ... }:
{ pkgs, config, lib, mayniklas, flake-self, ... }:
let primaryDisk = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S649NL0T853248L";
in {
  imports = [
    ../../users/lasse.nix
    ../../users/root.nix
    flake-self.inputs.disko.nixosModules.disko
  ];

  lgoette = {
    kde.enable = true;
    sound = {
      enable = true;
      pro-audio = true;
    };
    locale.enable = true;
  };
  users.extraUsers.lasse.extraGroups = [ "audio" "jackaudio" ];

  mayniklas = {
    user = { root.enable = true; };
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
    useUserPackages = true;

    extraSpecialArgs = {
      # Pass all flake inputs to home-manager modules aswell so we can use them
      # there.
      inherit flake-self;
      # Pass system configuration (top-level "config") to home-manager modules,
      # so we can access it's values for conditional statements
      system-config = config;
    };

    users.lasse = flake-self.homeConfigurations.desktop-audio;
  };

  # Add lightweight desktop environment
  # services.xserver = {
  #   enable = true;
  #   xkb.layout = "de";
  #   xkb.options = "eurosign:e";
  #   desktopManager.xfce.enable = true;
  # };
  # environment.xfce.excludePackages = with pkgs.xfce; [
  #   exo
  #   orage
  #   xfburn
  #   parole
  #   gigolo
  #   tumbler
  #   catfish
  #   xfce4-weather-plugin
  #   xfce4-volumed-pulse
  #   xfce4-timer-plugin
  #   xfce4-time-out-plugin
  #   xfce4-taskmanager
  #   xfce4-screenshooter
  #   xfce4-screensaver
  #   xfce4-pulseaudio-plugin
  #   xfce4-power-manager
  #   xfce4-notes-plugin
  # ];

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

  services.displayManager.autoLogin = {
    enable = true;
    user = "lasse";
  };

  security.sudo.extraRules = [
    {
      users = [ "lasse" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];

  networking = {
    hostName = "lamabus";
    firewall = {
      enable = false;
      allowedTCPPorts = [ 50937 ];
    };
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
      wineWowPackages.stable
      winePackages.stagingFull
      # airwave
      carla
      yabridge
      yabridgectl
      jack1
    ];

  systemd.user.services.carla = {
    wantedBy = [ "default.target" "graphical-session.target" ];
    environment.DISPLAY = ":0";
    environment.WAYLAND_DISPLAY = "wayland-0";
    environment.DEBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    environment.QT_QPA_PLATFORM = "wayland";
    environment.XDG_RUNTIME_DIR = "/run/user/1000";
    after = [ "plasma-workspace-wayland.target" "jack.service" ];
    path = [ "${pkgs.yabridge}" ];
    serviceConfig = {
      # User = "lasse";
      Type = "exec";
      #WorkingDirectory = "/home/lasse";
      ExecStop = "${pkgs.killall}/bin/killall -9 -r .*winedevice.exe";
    };
    script = ''
      ${pkgs.carla}/bin/carla ~/.carla/default.carxp
    '';
  };

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" "snd-seq" "snd-rawmidi" ];

  lollypops.deployment = {
    local-evaluation = false;
    ssh = {
      user = "root";
      host = "192.168.0.23"; # Diese ip ist alt
      opts = [ "-p 50937" ];
    };
  };

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 2);
  }];

  # Define disk layout
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = primaryDisk;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 1; # Needs to be first partition
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

  boot.loader.grub = {
    devices = [ primaryDisk ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = config.nixpkgs.config.allowUnfree;
  system.stateVersion = "22.05";

}
