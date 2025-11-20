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
      # minecraft-backup = {
      #   enable = true;
      #   enableWebservice = true;
      #   openFirewall = true;
      # };
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

  # services.minecraft-server = {
  #   enable = false;
  #   # For performance reasons, we choose to use the papermc fork
  #   # of minecraft-server.
  #   # The newest version of papermc can be found here:
  #   # https://papermc.io/downloads
  #   # We are overriding the version from the repositories to use the latest version.
  #   package = pkgs.papermc.overrideAttrs (finalAttrs: previousAttrs:
  #     let
  #       mcVersion = "1.21.4";
  #       buildNum = "100";
  #     in
  #     {
  #       version = "${mcVersion}.${buildNum}";
  #       src = pkgs.fetchurl {
  #         url =
  #           "https://api.papermc.io/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
  #         hash = "sha256-33oQsflEKB3fCQdv457VZgSqSmbs1CH+6j9vC1mA0YM=";
  #       };
  #     });
  #   dataDir = "/var/lib/minecraft";
  #   declarative = true;
  #   eula = true;
  #   jvmOpts =
  #     "-Xms2G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
  #   openFirewall = true;
  #   serverProperties = {
  #     enable-rcon = true;
  #     "rcon.password" = "minecraft";
  #     difficulty = 3;
  #     gamemode = 0;
  #     max-players = 12;
  #     motd =
  #       "\\u00a7e\\u273f\\u00a72\\u00a7lLamacraft\\u00a7e\\u273f\\n1.20.1 \\u00a74<3";
  #     white-list = true;
  #     entity-broadcast-range-percentage = 100;
  #     view-distance = 16;
  #     simulation-distance = 14;
  #   };
  #   whitelist = {
  #     #BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
  #     mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
  #     hellslime2000 = "41555a0b-9a6f-4596-98eb-d60ed5b02cb3";
  #     #Endslime2000 = "8e82ce9f-80fe-4a23-ab3e-464e0d3776f6";
  #     #EnderSnow_ = "73341ad1-dabb-4547-b00e-33fb1c488464";
  #     #hako55 = "df1fc00d-e816-4356-870c-a1492be67740";
  #     #PlanetMaker3000 = "e909c435-b18f-4bea-94c8-ead3b843f2c6";
  #     cukiGAN = "d276f577-8791-4d60-8a05-9dc0d16fcf59";
  #     "1gjxnx" = "dc58d757-3b29-4b69-b18c-164ac6ff156e";
  #     vivithere = "a7e7c9c9-203c-4feb-b094-e39639067847";
  #     Rocky0401 = "b15504ff-50f9-4fc4-a71b-86ebb2ba53b6";
  #     GummiLPs = "8c21bd0e-c067-4dc7-a857-52dfb8c3ed26";
  #     mia24_official = "bde2ece2-e806-4235-a237-785c2dafc4ff";
  #     TeeJay1306 = "49da54b2-5472-4c3f-92ec-00a3bb1a7f0e";
  #     ImJonazz = "82bcbf74-1488-4d76-a5fb-5bd3391db937";
  #     ESL_Eugen = "bea7add8-c91c-4ee6-b8c2-eff5df663037";
  #     aikoomi = "05a0e4cd-c4bb-4657-b484-f336751ea66b";
  #     #lyly97 = "947b948d-52ab-40aa-a295-76198e0b6b11";
  #     LukasGameTime = "20447a78-872a-461d-87d9-a015ab4af2cc";
  #     #emofr = "ae1c886b-75ba-47c2-a00b-20246205a355";
  #     UrLeastFavSimp = "4129d14f-74bb-4331-8d79-4832b0a758ba";
  #     mU_ffiN = "20748e98-2b90-4f4a-aadd-338eaed5b49b";
  #     #Kyla_ = "28bd90b2-6b45-4c13-89ec-aed3417e728e";
  #     MikrogamerHD = "61699963-4d1b-49ba-b945-8c3882713880";
  #   };
  #   # TODO: Add Overlay with ops option
  #   # ops = {
  #   #   BobderEhrenmann = {
  #   #     uuid = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
  #   #     level = 4;
  #   #   };
  #   #   mineslime2000 = {
  #   #     uuid = "d6d40e5f-75af-4713-b1fa-522229425116";
  #   #     level = 4;
  #   #     bypassesPlayerLimit = true;
  #   #   };
  #   #   cukiGAN = {
  #   #     uuid = "d276f577-8791-4d60-8a05-9dc0d16fcf59";
  #   #     level = 2;
  #   #   };
  #   # };
  # };

  # TODO: Anpassen auf nix-minecraft (minecraft-servers)
  # Ferien Zeit 10-3
  # Normale Zeit: 10-2
  # services.cron = {
  #   enable = false;
  #   systemCronJobs = [
  #     "50 1 * * *     root    echo 'say Server is shutting down in 10 minutes!' > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}"
  #     "0 2 * * *      root    ${pkgs.systemd}/bin/systemctl stop minecraft-server"
  #     "0 10 * * *      root    ${pkgs.systemd}/bin/systemctl start minecraft-server"
  #   ];
  # };

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
      25565
      50937
      9100
    ];
    firewall.allowedUDPPorts = [ 25565 ];

  };

  environment.systemPackages = with pkgs; [
    bash-completion
    git
    wget
  ];

  # swapfile empty because minecraft uses fixed ram
  swapDevices = [ ];

  # Use KVM / QEMU
  services.qemuGuest.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "22.05";

}
