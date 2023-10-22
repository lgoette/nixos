{ self, ... }:
{ lib, pkgs, config, mayniklas, home-manager, ... }:

{
  imports = [
    # ./minecraft.nix
    ../../users/lasse.nix
    ../../users/root.nix
    # home-manager.nixosModules.home-manager
  ];

  lgoette = {
    services.minecraft-backup = {
      enable = true;
      enableWebservice = true;
      openFirewall = true;
    };
    user.lasse.home-manager.enable = true;
  };

  mayniklas = {
    user = {
      root.enable = true;
      nik = { enable = true; };
    };
    home-manager.enable = true;
    var.mainUser = "lasse";
    locale.enable = true;
    openssh.enable = true;
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
    cloud.pve-x86.enable = true;
    zsh.enable = true;
  };

  services.minecraft-server = {
    enable = true;
    # For performance reasons, we choose to use the papermc fork
    # of minecraft-server.
    # The newest version of papermc can be found here:
    # https://papermc.io/downloads
    # We are overriding the version from the repositories to use the latest version.
    package = pkgs.papermc.overrideAttrs (finalAttrs: previousAttrs:
      let
        mcVersion = "1.20.2";
        buildNum = "243";
        src = pkgs.fetchurl {
          url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
          hash = "sha256-4eqyHIj0Oi+ssHiREOHdWWlhdlcfbChDuyWIyd5Dl+o=";
        };
      in
      {
        version = "${mcVersion}r${buildNum}";
        installPhase = ''
          install -D ${src} $out/share/papermc/papermc.jar
          makeWrapper ${lib.getExe pkgs.jre} "$out/bin/minecraft-server" \
            --append-flags "-jar $out/share/papermc/papermc.jar nogui"
        '';
      });
    dataDir = "/var/lib/minecraft";
    declarative = true;
    eula = true;
    jvmOpts = "-Xms2G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
    openFirewall = true;
    serverProperties = {
      enable-rcon = true;
      "rcon.password" = "minecraft";
      difficulty = 3;
      gamemode = 0;
      max-players = 12;
      motd =
        "\\u00a7e\\u273f\\u00a72\\u00a7lLamacraft\\u00a7e\\u273f\\n\1.20.1 \\u00a74<3";
      white-list = true;
      entity-broadcast-range-percentage = 100;
      view-distance = 16;
      simulation-distance = 14;
    };
    whitelist = {
      #BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
      mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
      hellslime2000 = "41555a0b-9a6f-4596-98eb-d60ed5b02cb3";
      #Endslime2000 = "8e82ce9f-80fe-4a23-ab3e-464e0d3776f6";
      #EnderSnow_ = "73341ad1-dabb-4547-b00e-33fb1c488464";
      #hako55 = "df1fc00d-e816-4356-870c-a1492be67740";
      #PlanetMaker3000 = "e909c435-b18f-4bea-94c8-ead3b843f2c6";
      cukiGAN = "d276f577-8791-4d60-8a05-9dc0d16fcf59";
      "1gjxnx" = "dc58d757-3b29-4b69-b18c-164ac6ff156e";
      vivithere = "a7e7c9c9-203c-4feb-b094-e39639067847";
      Rocky0401 = "b15504ff-50f9-4fc4-a71b-86ebb2ba53b6";
      GummiLPs = "8c21bd0e-c067-4dc7-a857-52dfb8c3ed26";
      mia24_official = "bde2ece2-e806-4235-a237-785c2dafc4ff";
      TeeJay1306 = "49da54b2-5472-4c3f-92ec-00a3bb1a7f0e";
      ImJonazz = "82bcbf74-1488-4d76-a5fb-5bd3391db937";
      ESL_Eugen = "bea7add8-c91c-4ee6-b8c2-eff5df663037";
      aikoomi = "05a0e4cd-c4bb-4657-b484-f336751ea66b";
      #lyly97 = "947b948d-52ab-40aa-a295-76198e0b6b11";
      LukasGameTime = "20447a78-872a-461d-87d9-a015ab4af2cc";
      #emofr = "ae1c886b-75ba-47c2-a00b-20246205a355";
      UrLeastFavSimp = "4129d14f-74bb-4331-8d79-4832b0a758ba";
      mU_ffiN = "20748e98-2b90-4f4a-aadd-338eaed5b49b";
      #Kyla_ = "28bd90b2-6b45-4c13-89ec-aed3417e728e";
      MikrogamerHD = "61699963-4d1b-49ba-b945-8c3882713880";
    };
    # TODO: Add Overlay with ops option
    # ops = {
    #   BobderEhrenmann = {
    #     uuid = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
    #     level = 4;
    #   };
    #   mineslime2000 = {
    #     uuid = "d6d40e5f-75af-4713-b1fa-522229425116";
    #     level = 4;
    #     bypassesPlayerLimit = true;
    #   };
    #   cukiGAN = {
    #     uuid = "d276f577-8791-4d60-8a05-9dc0d16fcf59";
    #     level = 2;
    #   };
    # };
  };

  # Ferien Zeit 10-3 
  # Normale Zeit: 10-2
  services.cron = {
    enable = true;
    systemCronJobs = [
      "50 1 * * *     root    echo 'say Server is shutting down in 10 minutes!' > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}"
      "0 2 * * *      root    ${pkgs.systemd}/bin/systemctl stop minecraft-server"
      "0 10 * * *      root    ${pkgs.systemd}/bin/systemctl start minecraft-server"
    ];
  };

  networking =
    let
      uplink_interface = "enp6s18";
      ip = "192.168.20.75";
      gateway = "192.168.20.1";
    in
    {
      hostName = "minecraft";

      dhcpcd.enable = false;
      enableIPv6 = false;
      defaultGateway = "${gateway}";
      nameservers = [ "1.1.1.1" "8.8.8.8" ];

      wireguard.interfaces.wg0 = {
        ips = [ "10.11.12.8/24" ];
        mtu = 1412;
        # Path to the private key file
        privateKeyFile = "/var/src/secrets/wireguard/private";
        peers = [{
          publicKey = "qBxrUEGSaf/P4MovOwoUO4PXOjznnWRjE7HoEyZMBBA=";
          allowedIPs = [ "10.11.12.0/24" "0.0.0.0/0" ];
          # hardcode wireguard endpoint
          # -> wireguard can be started with no DNS available
          endpoint = "5.45.108.206:53115";
          persistentKeepalive = 15;
        }];
      };

      interfaces = {
        ${uplink_interface}.ipv4 = {
          addresses = [
            {
              address = "${ip}";
              prefixLength = 24;
            }
          ];
          routes = [
            {
              address = "5.45.108.206";
              prefixLength = 32;
              via = "${gateway}";
              options = { metric = "0"; };
            }
            {
              address = "10.88.88.0";
              prefixLength = 24;
              via = "${gateway}";
              options = { metric = "202"; };
            }
            {
              address = "192.168.5.0";
              prefixLength = 24;
              via = "${gateway}";
              options = { metric = "202"; };
            }
          ];
        };
      };

      firewall.interfaces.enp6s18.allowedTCPPorts = [ 9100 ];

    };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
    ];

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 8);
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "22.05";

}
