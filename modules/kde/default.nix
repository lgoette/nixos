{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lgoette.kde;
in {

  options.lgoette.kde = { enable = mkEnableOption "activate kde"; };

  config = mkIf cfg.enable {

    # Enable the Plasma6 (5) Desktop Environment.
    services.displayManager = {
      # sddm.enable = true;
      sddm.wayland.enable = true; # TODO: Hat dat wat damit zu tun, dass Discord nicht startet?
      # sddm.theme = "${pkgs.sddm-chili-theme}/share/sddm/themes/chili"; # TODO: Warum funzt dat nicht?
    };

    services.xserver = {
      enable = true;
      # desktopManager.plasma5.enable = true;
      xkb.layout = "de";
      xkb.options = "eurosign:e";
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
