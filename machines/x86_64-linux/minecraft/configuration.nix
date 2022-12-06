{ lib, pkgs, mayniklas, home-manager, ... }:

{
  imports = [
    ../../../users/lasse.nix
    ../../../users/root.nix
    # home-manager.nixosModules.home-manager
  ];

  lgoette = {
    wg = {
      enable = true;
      ip = "10.11.12.8";
      allowedIPs = [ "10.11.12.0/24" "0.0.0.0/0" ];
      uplink_interface = "enp6s18";
    };
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
    minecraft-server = {
      enable = true;
      # For performance reasons, we choose to use the papermc fork
      # of minecraft-server.
      # The newest version of papermc can be found here:
      # https://papermc.io/downloads
      # We are overriding the version from the repositories to use the latest version.
      package = pkgs.papermc.overrideAttrs (finalAttrs: previousAttrs:
        let
          mcVersion = "1.19.2";
          buildNum = "304";
          jar = pkgs.fetchurl {
            url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
            sha256 = "sha256-UiTZPr8auvge7oYmhk+OedqyUlx0yq5ePW0ZkYUQdq0=";
          };
        in
        {
          version = "${mcVersion}r${buildNum}";
          installPhase = ''
            install -Dm444 ${jar} $out/share/papermc/papermc.jar
            install -Dm555 -t $out/bin minecraft-server
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
        max-players = 10;
        motd =
          "\\u00a7e\\u273f\\u00a72\\u00a7lLamacraft\\u00a7e\\u273f\\nMap: Ich hab keine Hobbys";
        white-list = true;
      };
      whitelist = {
        #BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
        mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
        #hellslime2000 = "41555a0b-9a6f-4596-98eb-d60ed5b02cb3";
        #Endslime2000 = "8e82ce9f-80fe-4a23-ab3e-464e0d3776f6";
        #EnderSnow_ = "73341ad1-dabb-4547-b00e-33fb1c488464";
        #hako55 = "df1fc00d-e816-4356-870c-a1492be67740";
        #PlanetMaker3000 = "e909c435-b18f-4bea-94c8-ead3b843f2c6";
        cukiGAN = "d276f577-8791-4d60-8a05-9dc0d16fcf59";
        "1gjxnx" = "dc58d757-3b29-4b69-b18c-164ac6ff156e";
        LovedByZyzz = "4feeb0a1-f64a-4214-ae16-5d75b09d6c8f";
        vivithere = "a7e7c9c9-203c-4feb-b094-e39639067847";
        Rocky0401 = "b15504ff-50f9-4fc4-a71b-86ebb2ba53b6";
      };
      ops = {
        BobderEhrenmann = {
          uuid = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
          level = 4;
        };
        mineslime2000 = {
          uuid = "d6d40e5f-75af-4713-b1fa-522229425116";
          level = 4;
          bypassesPlayerLimit = true;
        };
      };
    };
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

  networking = {
    hostName = "minecraft";
    dhcpcd.enable = false;
    enableIPv6 = false;
    interfaces.enp6s18.ipv4.addresses = [{
      address = "192.168.20.75";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.20.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.enp6s18.ipv4.routes = [
      {
        address = "10.88.88.0";
        prefixLength = 24;
        via = "192.168.20.1";
        options = { metric = "202"; };
      }
      {
        address = "192.168.5.0";
        prefixLength = 24;
        via = "192.168.20.1";
        options = { metric = "202"; };
      }
    ];
    firewall.interfaces.enp6s18.allowedTCPPorts = [ 9100 ];
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
      mcrcon
    ];

  # swapfile
  swapDevices = [{
    device = "/var/swapfile";
    size = (1024 * 8);
  }];

  system.stateVersion = "22.05";

}
