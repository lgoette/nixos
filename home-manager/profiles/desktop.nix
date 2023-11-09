{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    lasse = {
      programs.vscode.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      # pkgs
      arduino
      sublime
      blender
      chromium
      discord
      dolphin
      element
      firefox
      gcc
      gimp
      gparted
      htop
      iperf3
      nmap
      traceroute
      libreoffice
      obs-studio
      postman
      remmina
      signal-desktop
      simple-scan
      spotify
      synology-drive-client
      tdesktop
      thunderbird-bin
      unzip
      vlc
      youtube-dl
      zoom-us

      #mayniklas
      mayniklas.drone-gen
      mayniklas.vs-fix
    ];

  };
}
