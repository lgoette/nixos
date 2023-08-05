{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.services.minecraft-server;
in
{

  # define new options here
  options = { };

  config = mkIf cfg.enable {

    systemd.services.minecraft-server = {
      # replace pre-start with custom script
      preStart = lib.mkForce ''
        echo "custom pre-start"
      '';
    };
  };

}
