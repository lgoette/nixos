{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.lasse.programs.plasma;
in
{
  options.lasse.programs.plasma = {
    enable = mkEnableOption "enable plasma-manager for plasma desktop environment";
    pro-audio = mkEnableOption "enable plasma-manager for plasma desktop environment with pro-audio focus";
  };

  config = mkIf cfg.enable (mkMerge [

    # This block is always enabled
    {
      programs.plasma = {
        enable = true;
        overrideConfig = true;

        workspace = {
          clickItemTo = "select";
          theme = "breeze-dark";
          lookAndFeel = "org.kde.breezedark.desktop";
          wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images/5120x2880.png";
        };

        hotkeys.commands."open-settings" = {
          name = "Open Settings";
          key = "Meta+I";
          command = "systemsettings";
        };

        configFile = {
          # Toggle scroll direction (natural scrolling)
          kcminputrc."Libinput/2/7/SynPS\\/2 Synaptics TouchPad".NaturalScroll = true;

          # Deactivate "Shake cursor to find it"
          kwinrc."Plugins"."shakecursorEnabled" = false;

          # Custom buttons in window titlebar
          # left: More actions, On all desktops, Keep above other windows
          kwinrc."org.kde.kdecoration2".ButtonsOnLeft = "MSF";

          # right: Minimize, Maximize, Close
          kwinrc."org.kde.kdecoration2".ButtonsOnRight = "IAX";

          # Set splash screen theme
          ksplashrc."KSplash".Engine = "none";
          ksplashrc."KSplash".Theme = "None";

          # Set the Lock Screen wallpaper
          kscreenlockerrc = {
            "Greeter/Wallpaper/org.kde.image/General" =
              let
                image = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images/5120x2880.png";
              in
              {
                Image = image;
                PreviewImage = image;
              };
          };
        };

      };
    }

    (mkIf cfg.pro-audio {
      programs.plasma = {
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
                      "preferred://filemanager"
                      "org.kde.konsole.desktop"
                      "org.kde.plasma-systemmonitor.desktop"
                      "systemsettings.desktop"
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
                    "applications:carla.desktop"
                    "applications:org.rncbc.qjackctl.desktop"
                    "applications:vu.b4.alsa-scarlett-gui.desktop"
                  ];
                };
              }
              "org.kde.plasma.panelspacer"
              "org.kde.plasma.marginsseparator"
              # "org.kde.plasma.systemtray"
              # "org.kde.plasma.showdesktop"

              {
                systemTray = {
                  icons = {
                    spacing = "medium";
                    scaleToFit = false;
                  };
                  items = {
                    shown = [
                      "org.kde.plasma.battery"
                      "org.kde.plasma.networkmanagement"
                      "org.kde.plasma.bluetooth"
                      "org.kde.plasma.brightness"
                      "org.kde.plasma.volume"
                      "org.kde.plasma.notifications"
                      # "org.kde.plasma.clipboard"
                    ];
                    hidden = [
                      "org.kde.kalendar.contact"
                      "org.kde.plasma.clipboard"
                      "org.kde.kscreen"
                      "Discover Notifier_org.kde.DiscoverNotifier"
                      "Wallet Manager"
                      "KDE Daemon"
                      "The KDE Crash Handler"
                    ];
                  };
                };
              }
              "org.kde.plasma.digitalclock"

            ];
          }
        ];

        configFile = {
          # Prevent auto screen locking
          kscreenlockerrc = {
            "Daemon" = {
              "Autolock" = false;
              "LockOnResume" = false;
              "Timeout" = 0;
            };
          };
          # Disable windowdecorations because wine has a bug with touchscreen input where the titlebar is creating an unwanted offset
          kwinrulesrc = {
            "General" = {
              "count" = 1;
              "rules" = "Archetype";
            };
            "Archetype" = {
              "Description" = "Window settings for Neural DSP Archetype Plugins";
              "maximizevert" = true;
              "maximizevertrule" = 2;
              "noborder" = true;
              "noborderrule" = 2;
              "position" = "-3,0";
              "positionrule" = 2;
              "size" = "750,550";
              "sizerule" = 2;
              "title" = "Archetype";
              "titlematch" = 2;
              "wmclassmatch" = 1;
            };
          };
        };

      };

    })

    (mkIf (!cfg.pro-audio) {
      programs.plasma = {

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
                      "applications:com.yubico.yubioath.desktop"
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
                    "applications:signal.desktop"
                    "applications:com.yubico.yubioath.desktop"
                    "applications:code.desktop"
                  ];
                };
              }
              "org.kde.plasma.panelspacer"
              "org.kde.plasma.marginsseparator"
              # "org.kde.plasma.systemtray"
              # "org.kde.plasma.showdesktop"

              {
                systemTray = {
                  icons = {
                    spacing = "medium";
                    scaleToFit = false;
                  };
                  items = {
                    shown = [
                      "org.kde.plasma.battery"
                      "org.kde.plasma.networkmanagement"
                      "org.kde.plasma.bluetooth"
                      "org.kde.plasma.brightness"
                      "org.kde.plasma.volume"
                      "org.kde.plasma.notifications"
                      # "org.kde.plasma.clipboard"
                    ];
                    hidden = [
                      "org.kde.kalendar.contact"
                      "org.kde.plasma.clipboard"
                      "org.kde.kscreen"
                      "Discover Notifier_org.kde.DiscoverNotifier"
                      "Wallet Manager"
                      "KDE Daemon"
                      "The KDE Crash Handler"
                      "dev.deedles.Trayscale"
                    ];
                  };
                };
              }
              "org.kde.plasma.digitalclock"

            ];

            # Extra JS for configuring the system tray
            # extraSettings = (readFile (pkgs.substituteAll {
            #   src = ./system-tray.js;

            #   scaleIconsToFit = toString false;
            #   iconSpacing = toString 1;
            #   popupHeight = toString 500;
            #   popupWidth = toString 432;
            #   # Always shown
            #   shownItems = concatStringsSep "," [
            #     "org.kde.plasma.battery"
            #     "org.kde.plasma.networkmanagement"
            #     "org.kde.plasma.bluetooth"
            #     "org.kde.plasma.brightness"
            #     "org.kde.plasma.volume"
            #     "org.kde.plasma.notifications"
            #   ];

            #   # Always Hidden
            #   hiddenItems = concatStringsSep "," [
            #     "org.kde.kalendar.contact"
            #     "org.kde.plasma.clipboard"
            #     "org.kde.kscreen"
            #     "Discover Notifier_org.kde.DiscoverNotifier"
            #     "Wallet Manager"
            #     "KDE Daemon"
            #     "The KDE Crash Handler"
            #   ];
            # }));
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
        # startup.desktopScript."apply_panels".postCommands = ''
        #   echo "Restarting plasmashell..."
        #   sleep 1
        #   nohup plasmashell --replace &
        # '';
      };
    })
  ]);
}
