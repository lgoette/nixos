{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.kde;
in {

  options.lgoette.kde = { enable = mkEnableOption "activate kde"; };

  config = mkIf cfg.enable {

    # Enable the Plasma 5 Desktop Environment.
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
    };
    programs.kdeconnect.enable = true;
  };
}
