{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/mayniklas.keys";
        sha256 = "sha256-47KOHBE0eYZxHt9ENNNiD97jbBHeNq5lc83lOUFfjZw=";
      })
    ];
  };
}
