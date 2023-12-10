{
  description = "Simple flake for building chuffed";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = github:MiniZinc/libminizinc;
      flake = false;
    };

    # TODO
    chuffed.url = "../chuffed";
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    package,
    chuffed,
  }:
    flakeUtils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "libminizinc";
      src = package;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          CMAKE_MAKE_PROGRAM = "make -j $NIX_BUILD_CORES";

          # TODO compile with gecode
          # Fucking cmake says no, so this doesn't work
          GECODE_ROOT = "${pkgs.gecode}/include";

          buildInputs = with pkgs;
            [
              gecode
              cbc
              mpfr
              zlib
            ]
            ++ [chuffed.packages.${system}.default];

          nativeBuildInputs = with pkgs; [
            gecode
            cmake
            bison
            flex
            jq
          ];

          # Fuck cmake more
          #          buildPhase = "
          #            mkdir build
          #            cd build
          #            cmake .. -DGECODE_ROOT=$GECODE_ROOT
          #            ";

          meta = with nixpkgs.lib; {
            homepage = "https://www.minizinc.org/";
            description = "Libminizinc";
          };
        };
      };
    });
}
