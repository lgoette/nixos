{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nik = {
    isNormalUser = true;
    home = "/home/nik";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/mayniklas.keys";
        sha256 = "sha256-47KOHBE0eYZxHt9ENNNiD97jbBHeNq5lc83lOUFfjZw=";
      })
    ];
  };

  nix.allowedUsers = [ "nik" ];
}