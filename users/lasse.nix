{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lasse = {
    isNormalUser = true;
    home = "/home/lasse";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/lgoette.keys";
        sha256 = "sha256-CtLRR37JHtBs5detwNS18x+jRLaQeStb0urvbjO3O1Q=";
      })
    ];
  };

  nix.allowedUsers = [ "lasse" ];
}