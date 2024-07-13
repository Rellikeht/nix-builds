{
  inputs = {
    # {{{
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    sdk = {
      url = "github:Rellikeht/nix-builds?dir=pico-sdk";
    };

    examples = {
      url = "github:raspberrypi/pico-examples";
      flake = false;
    };
  }; # }}}

  outputs = {
    # {{{
    self,
    nixpkgs,
    flake-utils,
    sdk,
    examples,
    # }}}
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        sdk-pkg = sdk.packages.${system}.default;
        gcc = pkgs.gcc-arm-embedded;
      in rec {
        packages.default = pkgs.stdenv.mkDerivation {
          # {{{

          name = "pico-examples";
          src = examples;
          PICO_SDK_PATH = "${sdk-pkg}/lib/pico-sdk";

          phases = [
            "unpackPhase"
            "configurePhase"
            "buildPhase"
            "installPhase"
          ];

          nativeBuildInputs = with pkgs;
            [
              # {{{
              cmake
              python312
            ] # }}}
            ++ [
              gcc
            ];

          cmakeFlags = [
            "-D CMAKE_C_COMPILER=${gcc}/bin/arm-none-eabi-gcc"
            "-D CMAKE_CXX_COMPILER=${gcc}/bin/arm-none-eabi-g++"
          ];

          installPhase = ''
            mkdir -p $out
            cp -r * $out
            rm -rf $out/Makefile
            rm -rf $out/cmake_install.cmake
            rm -rf $out/pico-sdk
            rm -rf $out/pioasm
          '';

          # }}}
        };
      }
    );
}
