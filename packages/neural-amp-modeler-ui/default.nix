{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cairo,
  libX11,
  lv2,
  xxd,
  lib,
  neural-amp-modeler-lv2,
}:
# This builds brummer10's native X11/cairo UI for the Neural Amp Modeler LV2
# plugin and merges it into the plugin's own bundle.
#
# The UI is not a standalone bundle: upstream's `make install` copies its files
# into neural_amp_modeler.lv2 and replaces that bundle's manifest.ttl. The
# replacement manifest drops the `<modgui.ttl>` reference and points at the new
# UI instead, which is what gets rid of Carla's
# "ModuleNotFoundError: No module named 'PyQt5.QtWebKit'".
#
# Because the result declares the same plugin URI as neural-amp-modeler-lv2,
# install this package *instead of* that one, never both.
stdenv.mkDerivation {
  pname = "neural-amp-modeler-ui";
  version = "unstable-2026-06-07";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "neural-amp-modeler-ui";
    rev = "ee23316ceb47256273414dda1a5b640f35d41d4e";
    hash = "sha256-DvonS7YqHAnDDsxBoGMbfG/lnENve2aZ9NdWaKXxrAE=";
    fetchSubmodules = true;
  };

  # libxputty embeds its PNG resources with `xxd -i`, and errors out if neither
  # xxd nor xxdi.pl nor a suitable ld is found.
  nativeBuildInputs = [
    pkg-config
    xxd
  ];

  buildInputs = [
    cairo
    libX11
    lv2
  ];

  # Upstream's install target writes into the plugin's install prefix and needs
  # the plugin to already be there, so do the merge ourselves.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lv2
    cp -r ${neural-amp-modeler-lv2}/lib/lv2/neural_amp_modeler.lv2 $out/lib/lv2/
    chmod -R u+w $out/lib/lv2/neural_amp_modeler.lv2

    # The new manifest no longer references modgui.ttl, so drop the dead files.
    rm -rf $out/lib/lv2/neural_amp_modeler.lv2/modgui \
           $out/lib/lv2/neural_amp_modeler.lv2/modgui.ttl

    cp bin/Neural_Amp_Modeler_ui.lv2/* $out/lib/lv2/neural_amp_modeler.lv2/

    runHook postInstall
  '';

  # The merged bundle must expose the DSP, the new UI, and a manifest that ties
  # them together without mentioning modgui.
  doInstallCheck = true;
  installCheckPhase = ''
    bundle=$out/lib/lv2/neural_amp_modeler.lv2
    for f in neural_amp_modeler.so neural_amp_modeler.ttl \
             Neural_Amp_Modeler_ui.so Neural_Amp_Modeler_ui.ttl manifest.ttl; do
      test -f "$bundle/$f" || { echo "missing $f in merged bundle"; exit 1; }
    done
    grep -q 'Neural_Amp_Modeler_ui.ttl' "$bundle/manifest.ttl" \
      || { echo "manifest.ttl does not reference the new UI"; exit 1; }
    if grep -q 'modgui' "$bundle/manifest.ttl"; then
      echo "manifest.ttl still references modgui"; exit 1
    fi

    # The UI hardcodes port indices 4/5/6 (Input, Output, Quality). Older plugin
    # releases stop at 5, and the Quality knob would then drive a port that does
    # not exist, so refuse to build against a DSP without quality_scale.
    grep -q 'quality_scale' "$bundle/neural_amp_modeler.ttl" \
      || { echo "plugin has no quality_scale port; UI expects port index 6"; exit 1; }
  '';

  meta = {
    description = "Neural Amp Modeler LV2 plugin with brummer10's native X11 UI instead of the modgui";
    homepage = "https://github.com/brummer10/neural-amp-modeler-ui";
    platforms = lib.platforms.linux;
  };
}
