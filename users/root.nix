{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/lgoette.keys";
        hash = "sha256-tO5cED/b1eEuqvuGfzjAd3WhCO/oGvwRep0+jJA7B5E=";
      })
    ];
  };
}
