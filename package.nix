{ stdenv }:

stdenv.mkDerivation {
  name = "wez-status-styler";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    cp -r plugin $out;
  '';
}
