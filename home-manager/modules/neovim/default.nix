{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.neovim;
in {
  options.lasse.programs.neovim.enable = mkEnableOption "enable neovim";

  config = mkIf cfg.enable {

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
        ansible-vim
        i3config-vim
        vim-better-whitespace
        vim-nix
      ];
    };
  };
}
