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
      url = "github:raspberrypi/pico-sdk?submodule=1";
      flake = false;
    };
  }; # }}}

  outputs = {
    # {{{
    self,
    nixpkgs,
    flake-utils,
    sdk,
    # }}}
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      packages.default = pkgs.stdenv.mkDerivation {
        # {{{
        name = "pico-sdk";
        src = sdk;

        # nativeBuildInputs = with pkgs; [cmake];

        # SDK contains libraries and build-system to develop projects for RP2040 chip
        # We only need to compile pioasm binary
        # sourceRoot = "${sdk}/tools/pioasm";

        installPhase = ''
          # runHook preInstall
          cd $src
          mkdir -p $out/lib/pico-sdk
          cp -a * $out/lib/pico-sdk/
          # cp -a ../../../* $out/lib/pico-sdk/
          # chmod 755 $out/lib/pico-sdk/tools/pioasm/build/pioasm
          # runHook postInstall
        '';
      }; # }}}

      devShells.default = with pkgs;
        mkShell {
          # {{{
          buildInputs = with pkgs;
            [
              cmake
              gcc-arm-embedded
              libusb1
              openocd
              picotool

              screen
            ]
            ++ [
              packages.${system}.default
            ];

          shellHook = ''
            export PICO_SDK_PATH="${packages.default}/lib/pico-sdk"
          '';
        }; # }}}
    });
}
