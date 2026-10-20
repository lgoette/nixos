{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cairo,
  libX11,
  lv2,
  xxd,
  lib,
}:
stdenv.mkDerivation {
  pname = "neural-amp-modeler-ui";
  version = "unstable-2026-06-07";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "neural-amp-modeler-ui";
    rev = "ee23316ceb47256273414dda1a5b640f35d41d4e";
    hash = lib.fakeHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    xxd
  ];

  buildInputs = [
    cairo
    libX11
    lv2
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lv2
    cp -r bin/Neural_Amp_Modeler_ui.lv2 $out/lib/lv2/
    runHook postInstall
  '';

  meta = {
    description = "Native LV2 UI for the Neural Amp Modeler LV2 plugin";
    homepage = "https://github.com/brummer10/neural-amp-modeler-ui";
    platforms = lib.platforms.linux;
  };
}
