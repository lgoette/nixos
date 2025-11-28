{ pkgs, stdenv, ... }:
stdenv.mkDerivation {

  pname = "minecraft-backup";
  version = "0.1.0";

  # Needed if no src is used. Alternatively place script in
  # separate file and include it as src
  dontUnpack = true;

  installPhase =
    let
      minecraft-backup-skript = pkgs.writeShellScriptBin "minecraft-backup" ''
        backup_dir="$1"
        mc_dir="$2"
        mc_services="$3"

        # Liste der gestoppten Dienste (wird in umgekehrter Reihenfolge
        # aufgebaut, sodass beim Starten die ursprüngliche Reihenfolge
        # wiederhergestellt wird)
        stopped_services=""

        if [ -n "$mc_services" ]; then
          for svc in $mc_services; do
            if ${pkgs.systemd}/bin/systemctl is-active --quiet "$svc"; then
              if ${pkgs.systemd}/bin/systemctl stop "$svc"; then
                # prepend, damit die Startreihenfolge umgekehrt wird
                stopped_services="$svc $stopped_services"
              fi
            fi
          done

          # kurze Wartezeit, falls die Server Zeit zum Herunterfahren brauchen
          if [ -n "$stopped_services" ]; then
            sleep 60
          fi
        fi

        # Backup erstellen
        ${pkgs.zip}/bin/zip -r "$backup_dir/minecraft.zip" "$mc_dir"

        # Dienste wieder starten (in umgekehrter Reihenfolge der Stopps)
        if [ -n "$stopped_services" ]; then
          for svc in $stopped_services; do
            ${pkgs.systemd}/bin/systemctl start "$svc"
          done
        fi

        ${pkgs.coreutils}/bin/chown nginx:nginx "$backup_dir/minecraft.zip"
        ${pkgs.coreutils}/bin/chmod 550 "$backup_dir/minecraft.zip"
      '';
    in
    ''
      cp -r ${minecraft-backup-skript} $out
    '';
}
