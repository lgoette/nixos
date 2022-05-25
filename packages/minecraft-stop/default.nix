{ pkgs, stdenv, ... }:
stdenv.mkDerivation {

  pname = "minecraft-stop";
  version = "0.1.0";

  # Needed if no src is used. Alternatively place script in
  # separate file and include it as src
  dontUnpack = true;

  installPhase = let
    minecraft-stop-skript = pkgs.writeShellScriptBin "minecraft-stop" ''
      mc_dir=$1
      rcon_pw=$(cat "$mc_dir/server.properties" | grep "rcon.password" | cut -d'=' -f2)
      ${pkgs.mcrcon}/bin/mcrcon -H localhost -p $rcon_pw -w 5 save-all stop
    '';
  in ''
    cp -r ${minecraft-stop-skript} $out
  '';
}
