{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lasse = {
    isNormalUser = true;
    home = "/home/lasse";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys = {
      keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/lgoette.keys";
          hash = "sha256-NE7/VI5pKxcmjUWZaKEJ6vnOU0OjWIvdoN3WoR/1T4c=";
        })
      ];
    };
  };

  nix.settings.allowed-users = [ "lasse" ];
}
