{ pkgs, lib, config, ... }: # , mayniklas
with lib;
let
  plugins = with pkgs; [
    # Instruments
    x42-avldrums
    zynaddsubfx

    # Effects
    calf
    lsp-plugins
    distrho
    zam-plugins
    talentedhack
    gxplugins-lv2
  ];
in
{
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
      qjackctl
      alsa-scarlett-gui

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
      mayniklas.set-performance
      mayniklas.vs-fix
    ]
    ++ plugins;

    # Place vst, vst3, clap, lv2 and ladspa plugins in the according directories
    home.file =
      let
        all-audio-plugins = pkgs.symlinkJoin {
          name = "all-audio-plugins";
          paths = plugins;
        };
      in
      {
        all-lv2 = {
          recursive = true;
          source = "${all-audio-plugins}/lib/lv2";
          target = ".lv2";
        };
        all-clap = {
          recursive = true;
          source = "${all-audio-plugins}/lib/clap";
          target = ".clap";
        };
        all-vst = {
          recursive = true;
          source = "${all-audio-plugins}/lib/vst";
          target = ".vst";
        };
        all-vst3 = {
          recursive = true;
          source = "${all-audio-plugins}/lib/vst3";
          target = ".vst3";
        };
        all-ladspa = {
          recursive = true;
          source = "${all-audio-plugins}/lib/ladspa";
          target = ".ladspa";
        };
      };
  };

  };
}
