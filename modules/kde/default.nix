{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.kde;
in {

  options.lgoette.kde = { enable = mkEnableOption "activate kde"; };

  config = mkIf cfg.enable {

    # Enable the Plasma6 (5) Desktop Environment.
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
      # displayManager.sddm.theme = "${pkgs.sddm-chili-theme}/share/sddm/themes/chili"; # TODO: Warum funzt dat nicht?
      # desktopManager.plasma5.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
    };

    services.desktopManager.plasma6 = {
      enable = true;
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      # okular
      khelpcenter
    ];

    programs.kdeconnect.enable = true;
    programs.dconf.enable = true;
  };
}
