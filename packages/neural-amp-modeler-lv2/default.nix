{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  ...
}:
stdenv.mkDerivation {
  pname = "neural-amp-modeler-lv2";
  version = "0.2.3";

  src = fetchurl {
    url = "https://github.com/mikeoliphant/neural-amp-modeler-lv2/releases/download/v0.2.3/neural_amp_modeler_lv2_linux_x64.tgz";
    sha256 = "0pigzggwf43z3v8kkmiywq3zpfnx0cy0ilcr7x10yxsvad7x8rmq";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/lib/lv2
    cp -r neural_amp_modeler.lv2 $out/lib/lv2/
  '';
}
