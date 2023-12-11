{
  description = "Simple flake for building scip suite";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = github:scipopt/scip;
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    package,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = import "${nixpkgs}" {
        system = system;
        config.allowUnfree = true;
      };
      name = "SCIP";
      src = package;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation rec {
          inherit name system src;

          CMAKE_MAKE_PROGRAM = "make -j $NIX_BUILD_CORES";

          # TODO papilo :(
          buildInputs = with pkgs; [
            zlib
            boost
            ipopt
            metis
            gmp
            readline
            lapack
            cliquer
            openblas
            gsl
            tbb
            # hmetis
          ];

          nativeBuildInputs = with pkgs;
            [
              cmake
              m4
              flex
              bison
              file
              gfortran
              dpkg
              rpm
            ]
            ++ buildInputs;

          meta = with nixpkgs.lib; {
            homepage = "https://scipopt.org/";
            description = "SCIP solver suite";
          };
        };
      };
    });
}
