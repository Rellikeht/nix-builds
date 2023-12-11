{
  description = "Simple flake for building libminizinc";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = github:MiniZinc/libminizinc;
      flake = false;
    };

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

          buildInputs = with pkgs;
            [
              gecode
              cbc
              mpfr
              zlib
              or-tools
            ]
            ++ [
              chuffed.packages.${system}.default
            ];

          nativeBuildInputs = with pkgs; [
            or-tools
            gecode
            cmake
            bison
            flex
            jq
          ];

          # cmakeFlags = [
          #   "-DGecode_ROOT=${pkgs.gecode}/include"
          #   "-dGECODE_ROOT=${pkgs.gecode}/include"
          # ];

          # Sad workaround from nixpkgs, maybe this is
          # necessary to make shit work :(

          postInstall = with pkgs; ''
            mkdir -p $out/share/minizinc/solvers/

            jq \
              '.version = "${gecode.version}"
             | .mznlib = "${gecode}/share/gecode/mznlib"
             | .executable = "${gecode}/bin/fzn-gecode"' \
             ${./gecode.msc} \
             >$out/share/minizinc/solvers/gecode.msc

            jq \
              '.version = "${or-tools.version}"
             # | .mznlib = "${or-tools}/share/minizinc/ortools"
             | .executable = "${or-tools}/bin/fzn-ortools"' \
             ${./ortools.msc} \
             >$out/share/minizinc/solvers/ortools.msc

          '';

          meta = with nixpkgs.lib; {
            homepage = "https://www.minizinc.org/";
            description = "Libminizinc";
          };
        };
      };
    });
}
