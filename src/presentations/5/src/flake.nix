{
  description = "Go DevShell";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        treefmtconfig = inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "go.mod";
          programs = {
            gofmt.enable = true;
            prettier.enable = true;
            nixfmt.enable = true;
          };
        };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            CGO_ENABLED = 0;
            packages = with pkgs; [
              nixd
              nil
              go
              gopls
              delve
              gosimports
              texliveFull
              quarto
            ];
          };
        };
        formatter = treefmtconfig.config.build.wrapper;
        checks = {
          formatting = treefmtconfig.config.build.check self;
        };
      }
    );
}
