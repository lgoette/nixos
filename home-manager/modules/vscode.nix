{ lib, pkgs, config, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [

      brettm12345.nixfmt-vscode
      ms-azuretools.vscode-docker
      ms-python.python
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools
    ];
  };
}
