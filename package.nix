{ stdenv }:

stdenv.mkDerivation {
  name = "wez-status-generator";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    cp -r plugin $out;
  '';
}
