{ config, pkgs, lib, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lasse = {
    isNormalUser = true;
    home = "/home/lasse";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys = {
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq3P78Cwt2dfngRI2w3DXQCPCo+/UUHnxDea8WSmbg/BIlXJiqbT2RtU4JuAhSCLdc/j8dVa+ISa92v2bSoTpQ0/XEMmq0Qr7hgydtlx3CMqg2kUtaxLdnCeeop97a699yQSxJyrtiD09hWSHNb4mmgambbGNZZqEcspwGqsn+9NGPGj1KJGhbQbY/r8Vce5XZjXbFkFecvarcrvR0hiqQr8KGY8oqOGxFmlZQg6u3GpvbA+8c0QecrXTT+WxRt7IPG656UBUKCT/+CW1RVEAhukvAbIlq5eAtSlcI/an3wXi57yx6l/iA9RAksS0W7kcrEdpYnrC6HyWiIMu6GdCPsY+s7cGvyXtBdiLB+58rI6qm6hbn25DlBO6lXhWURXXRVwIJR/lHBUMuSvTgCEEbajXjmVTF1r53Alj1jznDAovIF0vxbJlqxlmqyY3Zos8ZwknUrqg59jb3KlKEFvNYQ7Z1LNd1yibjkBhxxAxUcBBubvog/niacoVQallca437G2/9g3CON/Uln+osGic76JKWjBUrceixLoRVk2PYUKFjCLfASt0e4caHAmI2m+7P3UrG7W/IaPOwkVVyeXUCN/qCzvvCp4X4txxvDTj2OZ4Nyr/zuZcxjvxuzaLgygOHx2+YhyadSS5KCLoTVEIYP5k86UiwuYg6LzRYGgCc/w=="
      ];
      keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/lgoette.keys";
          hash = "sha256-7qFXkCAtFM2k+AOHaUoT8pNYOoZPpvUZp8nERKHdGwc=";
        })
      ];
    };
  };

  nix.allowedUsers = [ "lasse" ];
}
