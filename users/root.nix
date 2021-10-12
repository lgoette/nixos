{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/MayNiklas.keys";
        sha256 = "174dbx0kkrfdfdjswdny25nf7phgcb9k8i6z3rqqcy9l24f8xcp3";
      })
      (pkgs.fetchurl {
        url = "https://github.com/lgoette.keys";
        sha256 = "0m1vnwrnxvzas9djnychnr2a67zknpac1bfpwmnd07n9gr3x3lha";
      })
    ];
  };
}
