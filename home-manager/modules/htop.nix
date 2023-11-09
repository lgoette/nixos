{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.htop; in
{
  options.lasse.programs.htop.enable = mkEnableOption "enable htop";

  config = mkIf cfg.enable {

    programs.htop = {
      enable = true;
      settings = {
        show_cpu_usage = true;
        show_program_path = false;
        tree_view = false;
      };
    };
  };
}
