{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.bluetooth;
in {

  options.lgoette.bluetooth = { enable = mkEnableOption "activate bluetooth"; };

  config = mkIf cfg.enable {

    hardware.bluetooth = {
      enable = true;
      # hsphfpd.enable = true;
    };

    # services.blueman.enable = true;
  };
}
