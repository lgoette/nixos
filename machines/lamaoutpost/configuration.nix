{ self, ... }:
{ pkgs, lib, mayniklas, home-manager, ... }:

{
  imports = [
    self.pi.pi4b
    ../../users/lasse.nix
    ../../users/root.nix
    ./wg0.nix
  ];


  lgoette = {
    user.lasse.home-manager.enable = true;
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

  networking = {
    hostName = "lamaoutpost";
    usePredictableInterfaceNames = false;
    firewall.allowedTCPPorts = [ 50937 ];
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
