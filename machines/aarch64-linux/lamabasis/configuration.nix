{ pkgs, lib, mayniklas, home-manager, ... }:

{
  imports = [
    ../../../users/lasse.nix
    ../../../users/root.nix
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
    #services.home-assistant.enable = true;
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

  # Enable librespot 
  # services.librespot = {
  #   enable = true;
  #   deviceName = "Lama2";
  # };

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
    firewall.allowedTCPPorts = [ 50937 ];
  };

  environment.systemPackages = with pkgs;
    with pkgs.mayniklas; [
      bash-completion
      git
      nixfmt
      wget
    ];

  system.stateVersion = "22.05";

}
