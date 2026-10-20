{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
# Wird bewusst aus Source gebaut statt das Upstream-Release-Binary zu nehmen.
#
# Upstream linkt seit 0.2.2 libstdc++ statisch ins Plugin ("static glibc for
# improved Linux binary portability") und exportiert dabei ~2900 std::-Symbole
# ungefiltert, davon 107 als STB_GNU_UNIQUE. Unique-Symbole fuehrt der Loader
# prozessweit auf eine Instanz zusammen, auch bei RTLD_LOCAL. Betroffen ist
# std::num_get<char>::id: dessen _M_index kommt dann aus der libstdc++ des
# Hosts (dort 4), waehrend das Facet-Array aus der statischen Kopie im Plugin
# stammt, wo Index 4 auf codecvt_w zeigt. use_facet<num_get> liefert damit das
# falsche Facet, der virtuelle Call in std::istream::operator>>(int&) landet in
# codecvt::do_unshift und schreibt den Flags-Wert 0xffffffff als Zeiger.
#
# Folge war ein reproduzierbarer SIGSEGV in Carla, sobald ein NAM-Modell
# geladen wurde (NAMIsA2 parst die Modellversion ueber einen stringstream).
# Aus Source gebaut wird libstdc++ dynamisch gelinkt, es gibt nur eine Instanz
# im Prozess, und das Problem entfaellt.
stdenv.mkDerivation (finalAttrs: {
  pname = "neural-amp-modeler-lv2";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    # Achtung: ab 0.2.x heissen die Tags "vX.Y.Z", 0.1.4 hiess noch ohne v.
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-TkynGmhwnkTqieJNuC+H2rDgxYZ9IFvqukfmtbSj790=";
  };

  nativeBuildInputs = [ cmake ];

  # Absichern, dass der Grund fuer den Source-Build erhalten bleibt: waere
  # libstdc++ wieder statisch drin, kaeme der Absturz unbemerkt zurueck.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    so=$out/lib/lv2/neural_amp_modeler.lv2/neural_amp_modeler.so
    test -f "$so" || { echo "neural_amp_modeler.so fehlt"; exit 1; }

    if ! readelf -d "$so" | grep -q 'NEEDED.*libstdc++\.so\.6'; then
      echo "libstdc++ ist nicht dynamisch gelinkt - Facet-Kollision droht"
      exit 1
    fi
    if nm -D --defined-only "$so" | grep -q 'num_getIcSt19istreambuf.*2idE'; then
      echo "Plugin exportiert std::num_get<char>::id - Facet-Kollision droht"
      exit 1
    fi

    runHook postInstallCheck
  '';

  meta = {
    description = "Neural Amp Modeler LV2 plugin implementation";
    homepage = "https://github.com/mikeoliphant/neural-amp-modeler-lv2";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
})
