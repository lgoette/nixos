{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/lgoette.keys";
        hash = "sha256-DNLHQJ0gz+kstDpiJvIigJ0dw6kw9CZGhA0RHSw3Wgc=";
      })
    ];
  };
}
