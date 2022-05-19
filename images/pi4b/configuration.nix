{ config, pkgs, lib, ... }: {

  imports = [

    # users
    ../../users/lasse.nix
    ../../users/root.nix

  ];

  mayniklas = {
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
  };

  environment.systemPackages = with pkgs; [ bash-completion git nixfmt wget ];

  networking = {
    hostName = "pi4b";
    interfaces.eth0 = { useDHCP = true; };
  };

  system.stateVersion = "22.05";

}
