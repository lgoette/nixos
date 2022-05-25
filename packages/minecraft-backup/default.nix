{ pkgs, stdenv, ... }:
stdenv.mkDerivation {

  pname = "minecraft-backup";
  version = "0.1.0";

  # Needed if no src is used. Alternatively place script in
  # separate file and include it as src
  dontUnpack = true;

  installPhase = let
    minecraft-backup-skript = pkgs.writeShellScriptBin "minecraft-backup" ''
      backup_dir=$1
      mc_dir=$2
      
      rcon_pw=$(cat "$mc_dir/server.properties" | grep "rcon.password" | cut -d'=' -f2)

      status=$(systemctl is-active minecraft-server.service)
      if [ $status == active ]; then
        active=true
      else
        active=false
      fi

      if ($active); then
        ${pkgs.mcrcon}/bin/mcrcon -H localhost -p $rcon_pw -w 5 save-all stop
        if [[ "$?" == "0" ]]; then
          sleep 5
          ${pkgs.zip}/bin/zip -r $backup_dir/minecraft.zip $mc_dir
          ${pkgs.systemd}/bin/systemctl start minecraft-server
          ${pkgs.coreutils}/bin/chown nginx:nginx $backup_dir/minecraft.zip
          ${pkgs.coreutils}/bin/chmod 550 $backup_dir/minecraft.zip
        fi
      else
        ${pkgs.zip}/bin/zip -r $backup_dir/minecraft.zip $mc_dir
        ${pkgs.coreutils}/bin/chown nginx:nginx $backup_dir/minecraft.zip
        ${pkgs.coreutils}/bin/chmod 550 $backup_dir/minecraft.zip
      fi

    '';
  in ''
    cp -r ${minecraft-backup-skript} $out
  '';
}
