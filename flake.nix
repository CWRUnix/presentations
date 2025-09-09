{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    gitignore.url = "github:hercules-ci/gitignore.nix";
  };
  outputs = {...} @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import inputs.nixpkgs) {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
          };
        };
        pythonPkg = pythonPackages:
          with pythonPackages; [
            ipykernel
            pandas
            pip
            numpy
            scipy
            sympy
            matplotlib
            pyyaml
            nbformat
            nbclient
            jupyter
          ];
      in {
        devShells = rec {
          quartoShell = let
          in
            pkgs.mkShell {
              packages = with pkgs; [
                (python3.withPackages pythonPkg)
                quarto
                texliveFull
                texworks
                texstudio
                typst
                librsvg
                chromium
              ];
              shellHook = ''
                export QUARTO_CHROMIUM_HEADLESS_MODE=new
              '';
            };
          default = quartoShell;
        };
        formatter = let
          treefmtconfig = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs = {
              alejandra.enable = true;
              black.enable = true;
              toml-sort.enable = true;
              yamlfmt.enable = true;
              mdformat.enable = true;
              prettier.enable = true;
              shellcheck.enable = true;
              shfmt.enable = true;
            };
            settings.formatter.shellcheck.excludes = [".envrc"];
          };
        in
          treefmtconfig.config.build.wrapper;
        apps = rec {
        };
        packages = rec {
          presentations = pkgs.callPackage ./nix/build.nix {inherit pythonPkg;};
          CI = presentations;
          default = presentations;
        };
      }
    );
}
