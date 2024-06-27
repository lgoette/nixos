{ pkgs, lib, config, ... }: # , mayniklas
with lib; {
  config = {

    # Home-manager nixpkgs config
    # nixpkgs.config = { 
    #   overlays = [ mayniklas.overlays.mayniklas ];
    # };

    lasse = {
      programs.plasma.enable = true;
      programs.git.enable = true;
    };

    # Install these packages for my user
    home.packages = with pkgs; [

      # Audio
      carla

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
      # barrier # TODO: Keyboard is us instead of de when starting input-leap
      input-leap # TODO: not working an wayland rightnow [wait for kde 6.1 (Tue 2024-06-18)] (https://invent.kde.org/plasma/xdg-desktop-portal-kde/-/issues/12; https://community.kde.org/Schedules/Plasma_6)
      yubioath-flutter

      # Kde
      kdePackages.dolphin
      kdePackages.kate
      kdePackages.ark
      kdePackages.kdeconnect-kde
      kdePackages.krfb
      libsForQt5.kpurpose
      kdePackages.kde-gtk-config
      kdePackages.kfind
      kdePackages.calendarsupport
      kdePackages.konsole
      kdePackages.kcalc

      # Office
      chromium

      # Media
      spotify
      vlc
      youtube-dl
      mixxx

      # Misc
      screenfetch

      #mayniklas
      mayniklas.drone-gen
      mayniklas.vs-fix
    ];

  };
}
