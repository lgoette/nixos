{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.lgoette.grub;
in
{

  options.lgoette.grub = {
    enable = mkEnableOption "activate grub";
  };

  config = mkIf cfg.enable {

    boot = {
      loader = {
        grub = {
          enable = true;
          version = 2;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = true;
          useOSProber = true;
        };
      };
      cleanTmpDir = true;
    };
  };
}
