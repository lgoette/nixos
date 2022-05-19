{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/lgoette.keys";
        hash = "sha256-hX9gcnrW+1hwSt5M0VRZl+i2O9iOy/EoZjYakn5FE+g=";
      })
    ];
  };
}
