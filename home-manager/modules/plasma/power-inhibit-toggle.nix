{ pkgs }:
pkgs.writeShellApplication {
  name = "power-inhibit-toggle";
  runtimeInputs = [
    pkgs.systemd
    pkgs.dbus
    pkgs.kdePackages.kconfig
  ];
  text = ''
    STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/power-inhibit.state"

    set_lid_action() {
      local action=$1
      for profile in "AC][HandleButtonEvents" "Battery][HandleButtonEvents" "LowBattery][HandleButtonEvents"; do
        kwriteconfig6 --file powermanagementprofilesrc --group "$profile" --key lidAction "$action"
      done
      dbus-send --session \
        --dest=org.kde.Solid.PowerManagement \
        /org/kde/Solid/PowerManagement \
        org.kde.Solid.PowerManagement.reparseConfiguration 2>/dev/null || true
    }

    if [ -f "$STATE_FILE" ]; then
      INHIBIT_PID=$(grep '^INHIBIT_PID=' "$STATE_FILE" | cut -d= -f2)
      ORIG_LID=$(grep '^ORIG_LID=' "$STATE_FILE" | cut -d= -f2)
      ORIG_AUTOLOCK=$(grep '^ORIG_AUTOLOCK=' "$STATE_FILE" | cut -d= -f2)
      ORIG_TIMEOUT=$(grep '^ORIG_TIMEOUT=' "$STATE_FILE" | cut -d= -f2)

      kill "$INHIBIT_PID" 2>/dev/null || true
      set_lid_action "$ORIG_LID"

      kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock "$ORIG_AUTOLOCK"
      kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout "$ORIG_TIMEOUT"
      dbus-send --session \
        --dest=org.kde.screensaver /ScreenSaver \
        org.kde.screensaver.configure 2>/dev/null || true

      rm -f "$STATE_FILE"
      dbus-send --session --print-reply --dest=org.kde.plasmashell /org/kde/osdService \
        org.kde.osdService.showText string:"system-suspend-uninhibited" string:"Sleep & lock re-enabled" > /dev/null
    else
      ORIG_LID=$(kreadconfig6 --file powermanagementprofilesrc --group "AC][HandleButtonEvents" --key lidAction --default 1)
      ORIG_AUTOLOCK=$(kreadconfig6 --file kscreenlockerrc --group Daemon --key Autolock --default true)
      ORIG_TIMEOUT=$(kreadconfig6 --file kscreenlockerrc --group Daemon --key Timeout --default 5)

      set_lid_action 0

      kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
      kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 0
      dbus-send --session \
        --dest=org.kde.screensaver /ScreenSaver \
        org.kde.screensaver.configure 2>/dev/null || true

      systemd-inhibit \
        --what=sleep \
        --who="power-inhibit-toggle" \
        --why="User requested" \
        --mode=block \
        sleep infinity &
      INHIBIT_PID=$!

      printf 'INHIBIT_PID=%s\nORIG_LID=%s\nORIG_AUTOLOCK=%s\nORIG_TIMEOUT=%s\n' \
        "$INHIBIT_PID" "$ORIG_LID" "$ORIG_AUTOLOCK" "$ORIG_TIMEOUT" > "$STATE_FILE"

      dbus-send --session --print-reply --dest=org.kde.plasmashell /org/kde/osdService \
        org.kde.osdService.showText string:"system-suspend-inhibited" string:"Sleep & lock blocked" > /dev/null
    fi
  '';
}
