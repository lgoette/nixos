{
  lib,
  pkgs,
  config,
  flake-self,
  ...
}:

{
  imports = [
    # ./minecraft.nix
    ../../users/lasse.nix
    ../../users/root.nix
  ];

  users.users.lasse.extraGroups = [ "minecraft" ];

  lgoette = {
    services = {
      minecraft-server.enable = true;
      minecraft-backup = {
        enable = true;
        enableWebservice = true;
        openFirewall = true;
      };
      minecraft-controller = {
        enable = true;
        schedule = {
          enable = false;
          start-time = "10:00"; # Normale Zeit: 10-2; Ferien Zeit 10-3
          stop-time = "02:00";
        };
      };
    };
  };

  mayniklas = {
    var.mainUser = "lasse";
    locale.enable = true;
    metrics = {
      node = {
        enable = true;
        flake = true;
      };
    };
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    cloud-provider-default.proxmox.enable = true;
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
    }
    // flake-self.inputs;

    users.lasse = flake-self.homeProfiles.server;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    startWhenNeeded = true;
    kbdInteractiveAuthentication = false;
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 50937;
      }
    ];
  };

  # Enable the Cloudflare Dyndns daemon.
  services.cloudflare-dyndns = {
    enable = true;
    proxied = false;
    ipv4 = true;
    domains = [ "lamacraft.lasse-goette.de" ];
    apiTokenFile = toString /var/src/secrets/cloudflare/token;
  };

  networking = {
    hostName = "minecraft";
    enableIPv6 = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    wireguard.interfaces.wg0 = {
      ips = [ "10.11.12.8/24" ];
      mtu = 1412;
      # Path to the private key file
      privateKeyFile = "/var/src/secrets/wireguard/private";
      peers = [
        {
          publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
          allowedIPs = [
            "10.11.12.1/32"
            "10.11.12.0/24"
          ];
          # hardcode wireguard endpoint
          # -> wireguard can be started with no DNS available
          endpoint = "5.252.227.28:53115";
          persistentKeepalive = 15;
        }
      ];
    };

    firewall.allowedTCPPorts = [
      25565 # Minecraft Server Port
      50937 # SSH Port
      9100
      8100 # Bluemap Port
    ];
    firewall.allowedUDPPorts = [ 25565 ];

  };

  environment.systemPackages = with pkgs; [
    bash-completion
    git
    wget
    tmux
  ];

  # swapfile empty because minecraft uses fixed ram
  swapDevices = [ ];

  # Use KVM / QEMU
  services.qemuGuest.enable = true;

  clan.core.networking.targetHost = "10.11.12.8:50937";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "22.05";

}
