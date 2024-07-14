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
      url = "https://github.com/raspberrypi/pico-sdk";
      flake = false;
      type = "git";
      submodules = true;
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
      packages = rec {
        # {{{

        pioasm = pkgs.stdenv.mkDerivation {
          # {{{
          name = "pioasm";
          src = "${sdk}/tools/pioasm";
          nativeBuildInputs = with pkgs; [cmake];

          installPhase = ''
            mkdir -p $out/bin
            cp pioasm $out/bin
            chmod 755 $out/bin/pioasm
          '';
        }; # }}}

        elf2uf2 = pkgs.stdenv.mkDerivation rec {
          # {{{
          name = "elf2uf2";
          src = "${sdk}";
          nativeBuildInputs = with pkgs; [cmake];
          sourceRoot = "source/tools/elf2uf2";

          installPhase = ''
            mkdir -p $out/bin
            cp elf2uf2 $out/bin
            chmod 755 $out/bin/elf2uf2
          '';
        }; # }}}

        default = pkgs.stdenv.mkDerivation {
          # {{{
          name = "pico-sdk";
          src = "${sdk}";

          phases = [
            "unpackPhase"
            "installPhase"
          ];

          installPhase = ''
            mkdir -p $out/lib/pico-sdk
            cp -a * $out/lib/pico-sdk

            mkdir -p $out/bin
            cp -a ${packages.elf2uf2}/bin/elf2uf2 $out/bin
            cp -a ${packages.elf2uf2}/bin/elf2uf2 $out/lib/pico-sdk/tools/elf2uf2/

            mkdir -p $out/bin
            cp -a ${packages.pioasm}/bin/pioasm $out/bin
            cp -a ${packages.pioasm}/bin/pioasm $out/lib/pico-sdk/tools/pioasm/
          '';

          #
        }; # }}}

        # }}}
      };

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
              packages.default
            ];

          shellHook = ''
            export PICO_SDK_PATH="${packages.default}/lib/pico-sdk"
          '';
        }; # }}}
    });
}
