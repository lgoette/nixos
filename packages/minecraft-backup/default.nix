{ pkgs, stdenv, ... }:
stdenv.mkDerivation {

  pname = "minecraft-backup";
  version = "0.1.0";

  # Needed if no src is used. Alternatively place script in
  # separate file and include it as src
  dontUnpack = true;

  installPhase = let
    minecraft-backup-skript = pkgs.writeShellScriptBin "minecraft-backup" ''
      status=$(systemctl is-active minecraft-server.service)
      if [ $status == active ]; then
        active=true
      else
        active=false
      fi

      if ($active); then
        ${pkgs.systemd}/bin/systemctl stop minecraft-server
        ${pkgs.zip}/bin/zip -r /var/www/minecraft-backup/minecraft.zip /var/lib/minecraft
        ${pkgs.systemd}/bin/systemctl start minecraft-server
        ${pkgs.coreutils}/bin/chown nginx:nginx /var/www/minecraft-backup/minecraft.zip
        ${pkgs.coreutils}/bin/chmod 550 /var/www/minecraft-backup/minecraft.zip

      else
        ${pkgs.zip}/bin/zip -r /var/www/minecraft-backup/minecraft.zip /var/lib/minecraft
        ${pkgs.coreutils}/bin/chown nginx:nginx /var/www/minecraft-backup/minecraft.zip
        ${pkgs.coreutils}/bin/chmod 550 /var/www/minecraft-backup/minecraft.zip
      fi
    '';
  in ''
    cp -r ${minecraft-backup-skript} $out
  '';
}
