{
  description = "Raspberry Pi Pico examples";

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
    examples,
    sdk,
    # }}}
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        # {{{
        pkgs = nixpkgs.legacyPackages.${system};
        sdk-pkg = sdk.packages.${system}.default;
        cc = pkgs.gcc-arm-embedded;
        # }}}
      in {
        packages.default = pkgs.stdenv.mkDerivation rec {
          # {{{

          # {{{
          name = "pico-examples";
          src = examples;
          PICO_SDK_PATH = "${sdk-pkg}/lib/pico-sdk";
          PICO_SDK_BIN = "${sdk-pkg}/bin";
          # }}}

          phases = [
            # {{{
            "unpackPhase"
            "patchPhase"
            "configurePhase"
            "buildPhase"
            "installPhase"
          ]; # }}}

          nativeBuildInputs = with pkgs;
            [
              # {{{
              cmake
              python312
            ] # }}}
            ++ [
              # {{{
              cc
            ]; # }}}

          cmakeFlags = [
            # {{{
            "-D CMAKE_C_COMPILER=${cc}/bin/arm-none-eabi-gcc"
            "-D CMAKE_CXX_COMPILER=${cc}/bin/arm-none-eabi-g++"
          ]; # }}}

          patchPhase =
            # {{{
            ''
              patch CMakeLists.txt < ${self}/CMakeLists.patch
            ''; # }}}

          installPhase =
            # {{{
            ''
              mkdir -p $out
              cp -r * $out
              rm -rf $out/Makefile
              rm -rf $out/cmake_install.cmake
              rm -rf $out/pico-sdk
              rm -rf $out/CMakeCache.txt
            ''; # }}}

          # }}}
        };
      }
    );
}
