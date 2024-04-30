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
        bbenoist.nix

        gruntfuggly.todo-tree
        editorconfig.editorconfig
        james-yu.latex-workshop
        yzhang.markdown-all-in-one
        esbenp.prettier-vscode

        ms-azuretools.vscode-docker
        ms-python.python
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers
        ms-vscode.cpptools
        ms-toolsai.jupyter
        ms-vsliveshare.vsliveshare

        github.copilot
        github.copilot-chat

        # tonybaloney.vscode-pets
      ];
    };
  };
}
