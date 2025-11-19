{
  stdenv,
  lib,
  qt5,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  glibc,
  cpio,
  xar,
  undmg,
  gtk3,
  pango,
}:
let
  pname = "synology-note-station-client";
  baseUrl = "https://global.download.synology.com/download/Utility/NoteStationClient";
  buildNumber = "609";
  version = "2.2.2";
  meta = with lib; {
    description = "Desktop application to synchronize Notes and ToDo lists between the computer and the Synology Note Station server.";
    homepage = "https://www.synology.com/en-global/dsm/feature/note_station";
    license = licenses.unfree;
    maintainers = with maintainers; [ lgoette ]; # Darf ich das?
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
  };

  linux = qt5.mkDerivation {
    inherit pname version meta;

    src = fetchurl {
      url = "${baseUrl}/${version}-${buildNumber}/Ubuntu/x86_64/synology-note-station-client-${version}-${buildNumber}.x86_64.deb";
      sha256 = "sha256-UAO/LwqPchIMhjdQP4METjVorMJsbvIDRkp4JxtZgOs="; # Ist noch alt
    };

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];

    buildInputs = [
      glibc
      gtk3
      pango
    ];

    # ab hier muss ich noch ändern
    unpackPhase = ''
      mkdir -p $out
      dpkg -x $src $out
      rm -rf $out/usr/lib/nautilus
      rm -rf $out/opt/Synology/SynologyDrive/package/cloudstation/icon-overlay
    '';

    installPhase = ''
      cp -av $out/usr/* $out
      rm -rf $out/usr
      runHook postInstall
    '';

    postInstall = ''
      substituteInPlace $out/bin/synology-drive --replace /opt $out/opt
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version meta;

    src = fetchurl {
      url = "${baseUrl}/${version}-${buildNumber}/Mac/x86_64/synology-note-station-client-${version}-${buildNumber}-mac-x64.dmg";
      sha256 = "15wici8ycil1mfh5cf89rfan4kb93wfkdsd4kmpvzjj4bnddwlxa"; # ist noch alt
    };

    nativeBuildInputs = [
      cpio
      xar
      undmg
    ];

    # ab hier muss ich wieder ändern
    postUnpack = ''
      xar -xf 'Install Synology Drive Client.pkg'
      cd synology-drive.installer.pkg
      gunzip -dc Payload | cpio -i
    '';

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications/
      cp -R 'Synology Drive Client.app' $out/Applications/
    '';
  };
in
if stdenv.isDarwin then darwin else linux
