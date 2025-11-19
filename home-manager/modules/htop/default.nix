{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.lasse.programs.htop;
in
{
  options.lasse.programs.htop.enable = mkEnableOption "enable htop";

  config = mkIf cfg.enable {

    programs.htop = {
      enable = true;
      settings = {
        show_cpu_frequency = true;
        show_cpu_temperature = true;
        show_cpu_usage = true;
        show_program_path = true;
        tree_view = false;
      };
    };
  };
}
