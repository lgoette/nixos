{ self, ... }:
{ pkgs, lib, mayniklas, home-manager, ... }:

{
  imports = [
    self.pi.pi4b
    ../../users/lasse.nix
    ../../users/root.nix
    ./wg0.nix
    # home-manager.nixosModules.home-manager
  ];

  # Sound on Raspberry Pi
  # boot = {
  #   extraModprobeConfig = ''
  #     options snd_bcm2835 enable_headphones=1
  #   '';
  # };

  # dtparam=audio=on in /boot/config.txt ?

  # hardware.raspberry-pi."4" = {
  #   audio.enable = true;
  # };

  lgoette = {
    user.lasse.home-manager.enable = true;
    home-assistant.enable = true;
    services.librespot = {
      enable = true;
      openFirewall = true;
      deviceType = "avr";
      name = "Lama";
    };
  };

  mayniklas = {
    var.mainUser = "lasse";
    locale.enable = true;
    docker = { enable = true; };
    nix-common = {
      enable = true;
      disable-cache = false;
    };
    zsh.enable = true;
  };

  users.users.leo = {
    isNormalUser = true;
    home = "/home/leo";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [  ];
  };

  fileSystems."/home/leo/musik" = {
    device = "/var/www/lamabasis.lasse-goette.de/res/music";
    fsType = "none";
    options = [ "bind" ];
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

  services.nginx = {
    enable = true;
    virtualHosts = {
      # TTT Loading Screen
      "lamabasis.lasse-goette.de" = {
        root = "/var/www/lamabasis.lasse-goette.de";
        locations = {
          "= /" = { return = "403"; extraConfig = "deny all;"; };
          "/" = {
            tryFiles = "$uri $uri.html =404";
            extraConfig = ''
              # https://www.cloudflare.com/ips

              # IPv4
              set_real_ip_from 173.245.48.0/20;
              set_real_ip_from 103.21.244.0/22;
              set_real_ip_from 103.22.200.0/22;
              set_real_ip_from 103.31.4.0/22;
              set_real_ip_from 141.101.64.0/18;
              set_real_ip_from 108.162.192.0/18;
              set_real_ip_from 190.93.240.0/20;
              set_real_ip_from 188.114.96.0/20;
              set_real_ip_from 197.234.240.0/22;
              set_real_ip_from 198.41.128.0/17;
              set_real_ip_from 162.158.0.0/15;
              set_real_ip_from 104.16.0.0/13;
              set_real_ip_from 104.24.0.0/14;
              set_real_ip_from 172.64.0.0/13;
              set_real_ip_from 131.0.72.0/22;

              # IPv6
              set_real_ip_from 2400:cb00::/32;
              set_real_ip_from 2606:4700::/32;
              set_real_ip_from 2803:f800::/32;
              set_real_ip_from 2405:b500::/32;
              set_real_ip_from 2405:8100::/32;
              set_real_ip_from 2a06:98c0::/29;
              set_real_ip_from 2c0f:f248::/32;

              real_ip_header CF-Connecting-IP;
              # real_ip_header X-Forwarded-For;

              # Generated at Wed Oct 11 01:02:31 CEST 2023

            '';
          };
        };
      };
    };
  };

  # Enable the Cloudflare Dyndns daemon.
  services.cloudflare-dyndns = {
    enable = true;
    proxied = false;
    ipv4 = true;
    domains = [ "lamabasis.lasse-goette.de" ];
    apiTokenFile = toString /var/src/secrets/cloudflare/token;
  };

  networking = {
    hostName = "lamabasis";
    usePredictableInterfaceNames = false;
    firewall.allowedTCPPorts = [ 50937 80 443 ];
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
    ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "22.05";

}
