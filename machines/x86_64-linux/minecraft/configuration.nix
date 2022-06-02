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
      uplink_interface = "ens192";
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
      dataDir = "/var/lib/minecraft";
      declarative = true;
      eula = true;
      jvmOpts = "-Xms2048m -Xmx6656m";
      openFirewall = true;
      serverProperties = {
        enable-rcon = true;
        "rcon.password" = "minecraft";
        difficulty = 3;
        gamemode = 0;
        max-players = 10;
        motd =
          "\\u00a7e\\u273f\\u00a72\\u00a7lLamacraft\\u00a7e\\u273f\\nMap: Brave New World";
        white-list = true;
      };
      whitelist = {
        BobderEhrenmann = "55df1dd6-8232-47f5-abbf-67c8f49ad26f";
        mineslime2000 = "d6d40e5f-75af-4713-b1fa-522229425116";
        hellslime2000 = "41555a0b-9a6f-4596-98eb-d60ed5b02cb3";
        Endslime2000 = "8e82ce9f-80fe-4a23-ab3e-464e0d3776f6";
        EnderSnow_ = "73341ad1-dabb-4547-b00e-33fb1c488464";
        hako55 = "df1fc00d-e816-4356-870c-a1492be67740";
        PlanetMaker3000 = "e909c435-b18f-4bea-94c8-ead3b843f2c6";
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
      node.enable = true;
      flake.enable = true;
    };
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    cloud.vmware-x86.enable = true;
    zsh.enable = true;
  };

  networking = {
    hostName = "minecraft";
    dhcpcd.enable = false;
    enableIPv6 = false;
    interfaces.ens192.ipv4.addresses = [{
      address = "192.168.20.75";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.20.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.ens192.ipv4.routes = [
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
    firewall.interfaces.ens192.allowedTCPPorts = [ 9100 ];
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
