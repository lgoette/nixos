{ lib, stdenv, fetchurl, nixosTests, jre_headless }:
stdenv.mkDerivation rec {
  version = "1.19.2";
  pname = "papermc";

  # https://papermc.io/downloads#Paper-1.19
  src = fetchurl {
    url = "https://api.papermc.io/v2/projects/paper/versions/${version}/builds/304/downloads/paper-${version}-304.jar";
    hash = "sha256-UiTZPr8auvge7oYmhk+OedqyUlx0yq5ePW0ZkYUQdq0=";
  };

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar

    cat > $out/bin/papermc << EOF
    #!/bin/sh
    exec ${jre_headless}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
    EOF

    chmod +x $out/bin/papermc
  '';

  phases = "installPhase";

  meta = with lib; {
    description =
      "Paper is the next generation of Minecraft servers, compatible with Spigot plugins, offering uncompromising performance.";
    homepage = "https://papermc.io/";
    license = licenses.unfreeRedistributable;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mayniklas ];
  };
}
