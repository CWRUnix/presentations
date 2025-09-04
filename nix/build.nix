{ stdenv, quarto, texliveFull, texworks, texstudio, librsvg, chromium, python3, pythonPkg, ... }:
stdenv.mkDerivation {
  pname = "CWRUnix-presentations";
  version = "0.0.1";
  src = ./../src;

  nativeBuildInputs = [
    (python3.withPackages (pythonPkg))
    quarto
    texliveFull
    texworks
    texstudio
    librsvg
    chromium
  ];

  buildPhase = ''
    mkdir home
    export HOME=$(realpath ./home)
    quarto render .
  '';
  installPhase = ''
    mkdir -p $out
    cp -r _output/* $out
  '';
}