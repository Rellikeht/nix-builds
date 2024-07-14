{
  description = "Raspberry Pi Pico SDK with submodules and some nice additions";

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

    pinout = {
      url = "https://gabmus.org/pico_pinout";
      flake = false;
    };
  }; # }}}

  outputs = {
    # {{{
    self,
    nixpkgs,
    flake-utils,
    sdk,
    pinout,
    # }}}
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      packages = {
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

        pico-mount =
          pkgs.writeScriptBin "pico-mount"
          # {{{
          ''
            #!${pkgs.dash}/bin/dash

            if [ "$(id -u)" != 0 ]; then
              echo This script must be run with root priviledges
              exit 1
            fi

            PICO_DIR=/mnt/pico
            if [ -n "$1" ]; then
              if [ -d "$1" ]; then
                PICO_DIR="$1"
              else
                echo "$1" is not a directory
                exit 1
              fi
            fi

            find /dev/ -name 'sd?1' |
              sort -r |
              xargs -d '\n' -I{} mount "{}" "$PICO_DIR"
          ''; # }}}

        pico-load =
          pkgs.writeScriptBin "pico-load"
          # {{{
          ''
            #!${pkgs.dash}/bin/dash

            if [ "$(id -u)" != 0 ]; then
              echo This script must be run with root priviledges
              exit 1
            fi

            if [ -z "$1" ];
              echo You need to specify program to load
              exit 1
            elif [ "$1" != "uf2" ]
              echo Is the format of "$1" correct?
              exit 1
            fi

            PICO_DIR=/mnt/pico
            if [ -n "$2" ]; then
              if [ -d "$2" ]; then
                PICO_DIR="$2"
              else
                echo "$2" is not a directory
                exit 1
              fi
            fi

            cp "$1" "$PICO_DIR"
            sync
            umount "$PICO_DIR"
          ''; # }}}

        pico-pinout =
          pkgs.writeScriptBin "pico-pinout"
          # {{{
          ''
            #!${pkgs.dash}/bin/dash

            less --quit-if-one-screen --raw-control-chars ${pinout}
          ''; # }}}

        pico-build =
          pkgs.writeScriptBin "pico-build"
          # {{{
          ''
            #!${pkgs.dash}/bin/dash

            mkdir -p build
            mkdir -p bin
            cd build
            cmake ..
            make -j
            cp *.uf2 ../bin
          ''; # }}}

        # # Magical workaround
        # sh = pkgs.symlinkJoin {
        #   # {{{
        #   name = "sh";
        #   paths = [pkgs.dash];
        #   postBuild = ''
        #     ln -s $out/bin/dash $out/bin/sh
        #   '';
        # }; # }}}

        default = pkgs.stdenv.mkDerivation {
          # {{{
          name = "pico-sdk";
          src = "${sdk}";

          installPhase =
            # {{{
            ''
              mkdir -p $out/lib/pico-sdk
              cp -a * $out/lib/pico-sdk

              mkdir -p $out/bin
              cp -a ${packages.elf2uf2}/bin/elf2uf2 $out/bin
              cp -a ${packages.elf2uf2}/bin/elf2uf2 $out/lib/pico-sdk/tools/elf2uf2/
              cp -a ${packages.pioasm}/bin/pioasm $out/bin
              cp -a ${packages.pioasm}/bin/pioasm $out/lib/pico-sdk/tools/pioasm/

              cp ${packages.pico-mount}/bin/pico-mount $out/bin
              cp ${packages.pico-load}/bin/pico-load $out/bin
              cp ${packages.pico-pinout}/bin/pico-pinout $out/bin
              cp ${packages.pico-build}/bin/pico-build $out/bin
            ''; # }}}

          #
        }; # }}}

        # }}}
      };

      apps = {
        # {{{

        pico-mount = {
          type = "app";
          program = "${packages.pico-mount}/bin/pico-mount";
        };

        pico-load = {
          type = "app";
          program = "${packages.pico-load}/bin/pico-load";
        };

        pico-pinout = {
          type = "app";
          program = "${packages.pico-pinout}/bin/pico-pinout";
        };

        pico-build = {
          type = "app";
          program = "${packages.pico-build}/bin/pico-build";
        };

        #
      }; # }}}

      devShells.default = let
        # {{{
        cc = pkgs.gcc-arm-embedded;
        # }}}
      in
        with pkgs;
          mkShell rec {
            # {{{
            buildInputs = with pkgs;
              [
                # {{{
                cmake
                libusb1
                openocd
                picotool
                screen

                # without that nix exports noninteractive version
                bashInteractive

                clang-tools
              ] # }}}
              ++ [
                # {{{
                packages.default
                cc
              ]; # }}}

            shellHook =
              # {{{
              ''
                export PICO_SDK_PATH="${packages.default}/lib/pico-sdk"
                export PICO_SDK_BIN="${packages.default}/bin"
                export CC=${cc}/bin/arm-none-eabi-gcc

                # Clangd refuses to fully cooperate
                # export CPATH="$CPATH:${packages.default}/lib/pico-sdk/**:${gcc}/**"
              ''; # }}}
          }; # }}}
    });
}
