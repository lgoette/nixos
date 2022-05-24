{ pkgs, lib, mayniklas, home-manager, ... }:

{
  imports = [
    ../../../users/lasse.nix
    ../../../users/root.nix
    # home-manager.nixosModules.home-manager
  ];

  lgoette = { user.lasse.home-manager.enable = true; };

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

  networking = { hostName = "lamabasis"; };

  home-manager.users.lasse.home.packages =
    with mayniklas.packages.x86_64-linux; [
      drone-gen
      vs-fix
    ];

  environment.systemPackages = with pkgs; [ bash-completion git nixfmt wget ];

  system.stateVersion = "22.05";

}
