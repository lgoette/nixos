{ lib, pkgs, config, ... }: {
  programs.htop = {
    enable = true;
    settings = {
      show_cpu_usage = true;
      show_program_path = false;
      tree_view = false;
    };
  };
}
