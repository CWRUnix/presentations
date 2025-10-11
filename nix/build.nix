{
  stdenv,
  quarto,
  texliveFull,
  texworks,
  texstudio,
  librsvg,
  chromium,
  typst,
  which,
  python3,
  pythonPkg,
  dejavu_fonts,
  ...
}:
stdenv.mkDerivation {
  pname = "CWRUnix-presentations";
  version = "0.0.1";
  src = ./../src;

  nativeBuildInputs = [
    (python3.withPackages pythonPkg)
    quarto
    texliveFull
    texworks
    texstudio
    librsvg
    chromium
    typst
    which
  ];

  buildPhase = ''
    ln -s ${dejavu_fonts} fonts
    mkdir home
    export HOME=$(realpath ./home)
    quarto render .
  '';
  installPhase = ''
    mkdir -p $out
    cp -r _output/* $out
  '';
}
