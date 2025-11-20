{
  config,
  flake-self,
  ...
}:
{
  imports = [
    ../../users/lasse.nix
    ../../users/root.nix
  ];

  mayniklas = {
    var.mainUser = "lasse";
    locale.enable = true;
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

  services.getty.autologinUser = "root";

  networking = {
    hostName = "lamabuild";
    enableIPv6 = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    firewall.allowedTCPPorts = [ 50937 ];

    wireguard.interfaces.wg0 = {
      ips = [ "10.11.12.7/24" ];
      metric = 1412;
      # Path to the private key file
      privateKeyFile = toString /var/src/secrets/wireguard/private;

      peers = [

        # 10.11.12.100
        {
          publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
          allowedIPs = [
            "10.11.12.1"
            "10.11.12.5"
            "10.11.12.6"
            "10.11.12.8"
          ];
          persistentKeepalive = 15;
          endpoint = "lamafarm.lasse-goette.de:53115";
        }

      ];

    };

  };

  # Use KVM / QEMU
  services.qemuGuest.enable = true;

  clan.core.networking.targetHost = "10.11.12.7:50937";

}
