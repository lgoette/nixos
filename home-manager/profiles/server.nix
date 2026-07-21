{
  pkgs,
  lib,
  vscode-server,
  ...
}:
with lib;
{
  imports = [ vscode-server.homeModules.default ];

  config = {
    # Install these packages for my user
    home.packages = with pkgs; [
      #pkgs
      iperf3
      nmap
      traceroute
      iftop
      unzip
      mcrcon
    ];

    services.vscode-server.enable = true;
  };
}
