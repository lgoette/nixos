{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lasse.programs.plasma; in
{
  options.lasse.programs.plasma.enable = mkEnableOption "enable plasma-manager for plasma desktop environment";

  config = mkIf cfg.enable {

    programs.plasma = {
      enable = true;
      overrideConfig = true;

      workspace = {
        clickItemTo = "select";
        theme = "breeze-dark";
        lookAndFeel = "org.kde.breezedark.desktop";
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images/5120x2880.png";
      };

      panels = [
        # Windows-like panel at the bottom
        {
          location = "bottom";
          height = 50;
          floating = true;
          hiding = "none";
          widgets = [
            "org.kde.plasma.pager"
            "org.kde.plasma.panelspacer"
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General = {
                  icon = "nix-snowflake";
                  favoritesPortedToKAstats = "false";
                  favorites = concatStringsSep "," [
                    "preferred://browser"
                    "applications:thunderbird.desktop"
                    "preferred://filemanager"
                    "org.kde.konsole.desktop"
                    "org.kde.plasma-systemmonitor.desktop"
                    "systemsettings.desktop"
                    "applications:com.yubico.authenticator.desktop"
                  ];
                };
              };
            }
            # We can also configure the widgets. For example if you want to pin
            # konsole and dolphin to the task-launcher the following widget will
            # have that.
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General.launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:firefox.desktop"
                  "applications:thunderbird.desktop"
                  "applications:signal-desktop.desktop"
                  "applications:com.yubico.authenticator.desktop"
                  "applications:code.desktop"
                ];
              };
            }
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
            # "org.kde.plasma.showdesktop"
          ];

          # Extra JS for configuring the system tray
          extraSettings = (readFile (pkgs.substituteAll {
            src = ./system-tray.js;

            scaleIconsToFit = toString false;
            iconSpacing = toString 1;
            popupHeight = toString 500;
            popupWidth = toString 432;
            # Always shown
            shownItems = concatStringsSep "," [
              "org.kde.plasma.battery"
              "org.kde.plasma.networkmanagement"
              "org.kde.plasma.bluetooth"
              "org.kde.plasma.brightness"
              "org.kde.plasma.volume"
              "org.kde.plasma.notifications"
            ];

            # Always Hidden
            hiddenItems = concatStringsSep "," [
              "org.kde.kalendar.contact"
              "org.kde.plasma.clipboard"
              "org.kde.kscreen"
              "Discover Notifier_org.kde.DiscoverNotifier"
              "Wallet Manager"
              "KDE Daemon"
              "The KDE Crash Handler"
            ];
          }));
        }

        # Global menu at the top
        # {
        #   location = "top";
        #   height = 26;
        #   widgets = [
        #     "org.kde.plasma.appmenu"
        #   ];
        # }

      ];
      # Restart plasmashell after applying panels (needed for custom popup size)
      startup.desktopScript."apply_panels".postCommands = ''
        echo "Restarting plasmashell..."
        sleep 1
        nohup plasmashell --replace &
      '';

      hotkeys.commands."open-settings" = {
        name = "Open Settings";
        key = "Meta+I";
        command = "systemsettings";
      };

      configFile = {
        # Toggle scroll direction (natural scrolling)
        "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."NaturalScroll".value = true;

        # Custom buttons in window titlebar
        # left: More actions, On all desktops, Keep above other windows
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft".value = "MSF";

        # right: Minimize, Maximize, Close
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight".value = "IAX";

        # Set splash screen theme
        "ksplashrc"."KSplash"."Engine".value = "none";
        "ksplashrc"."KSplash"."Theme".value = "None";

        # Set the Lock Screen wallpaper
        # TODO: This doesn't work, need to figure out how to set the lock screen wallpaper
        # kscreenlockerrc = {
        #   # Double-escaping is dumb but works
        #   "Greeter"."Wallpaper"."org.kde.image"."General" =
        #   let
        #     image = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images/5120x2880.png";
        #   in
        #   {
        #     "Image".value = image;
        #     "PreviewImage".value = image;
        #   };
        # };
      };
    };
  };
}
