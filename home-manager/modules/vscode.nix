{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.vscode; in
{
  options.lasse.programs.vscode.enable = mkEnableOption "enable vscode";

  config = mkIf cfg.enable {

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [

        brettm12345.nixfmt-vscode
        ms-azuretools.vscode-docker
        ms-python.python
        ms-vscode-remote.remote-ssh
        ms-vscode.cpptools
        # Todo tree
        # Copilot
      ];
    };
  };
}
