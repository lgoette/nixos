{ pkgs, lib, config, ... }: # , mayniklas
with lib;
{
  config = {

    # Home-manager nixpkgs config
    # nixpkgs.config = { 
    #   overlays = [ mayniklas.overlays.mayniklas ];
    # };

    lasse = {
      programs.vscode.enable = true;
      programs.plasma.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [

      # Common
      nfs-utils
      samba
      pavucontrol
      gparted
      unzip
      htop
      iperf3
      nmap
      traceroute
      remmina
      barrier


      # Kde
      kdePackages.dolphin
      kdePackages.kate
      kdePackages.ark
      kdePackages.kdeconnect-kde
      kdePackages.krfb
      libsForQt5.kpurpose
      kdePackages.kfind
      kdePackages.calendarsupport
      kdePackages.konsole

      # Development
      python3
      arduino
      # postman

      # Office
      chromium
      firefox
      thunderbird-bin
      libreoffice
      simple-scan
      synology-drive-client
      obsidian

      # Media
      spotify
      vlc
      youtube-dl

      # Comunication
      signal-desktop
      tdesktop
      discord
      element

      # Creativity
      blender
      gimp

      # Misc
      cobang
      android-tools
      scrcpy

      # Uni
      gcc
      conda

      #mayniklas
      mayniklas.drone-gen
      mayniklas.vs-fix
    ];

  };
}
