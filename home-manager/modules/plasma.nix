{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.plasma; in
{
  options.lasse.programs.plasma.enable = mkEnableOption "enable plasma-manager for plasma desktop environment";

  config = mkIf cfg.enable {
    
    programs.plasma = {
      enable = true;
      overrideConfig = true;
      configFile = {
        # Custom buttons in window titlebar
        # left: More actions, On all desktops, Keep above other windows
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft".value = "MSF";

        # right: Minimize, Maximize, Close
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight".value = "IAX";
      };
    };
  };
}