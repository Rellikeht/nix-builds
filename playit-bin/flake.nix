{
  description = "Binary build of playit client";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;

    pkg-linux-x64 = {
      url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.12/playit-linux-amd64";
      type = "file";
      flake = false;
    };

    # pkg-linux-x86 = {
    #   url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.12/playit-linux-i686";
    #   type = "file";
    #   flake = false;
    # };

    # pkg-linux-a64 = {
    #   url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.12/playit-linux-aarch64";
    #   type = "file";
    #   flake = false;
    # };

    # pkg-linux-a32 = {
    #   url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.12/playit-linux-armv7";
    #   flake = false;
    # };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    pkg-linux-x64,
    # pkg-linux-x86,
    # pkg-linux-a64,
    # pkg-linux-a32,
  }: let
    systems = {
      "x86_64-linux" = pkg-linux-x64;
      # "i686-linux" = pkg-linux-x86;
      # "aarch64-linux" = pkg-linux-a64;
      # "armv7l-linux" = pkg-linux-a32;
    };

    b = builtins;
    flib = flakeUtils.lib;
  in
    flib.eachSystem (b.attrNames systems) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "playit-bin";
      src = systems.${system};
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          buildInputs = with pkgs; [
            # qt6.qtbase
            # qt6.qtwebsockets
            # libglvnd
            # util-linux

            # gcc
            glibc

            # zlib
            # e2fsprogs
            # gmpxx
          ];

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            coreutils
          ];

          # sourceRoot = ".";
          # installPhase = ''
          #   runHook preInstall

          #   mkdir -p $out
          #   cp -r ${src}/lib $out
          #   cp -r ${src}/plugins $out
          #   cp -r ${src}/share $out

          #   cp -r ${src}/bin $out
          #   # mkdir -p $out/bin
          #   # find ${src}/bin -executable -type f -print0 |\
          #   #   xargs -0 -I{} cp {} "$out/bin"

          #   runHook postInstall
          # '';

          meta = with lib; {
            homepage = "https://playit.gg/";
            description = "Binary release of playit agent";
            license = licenses.bsd2;
            mainProgram = "playit";
            maintainers = ["Rellikeht"];
            platforms = platforms.linux; # ???

            longDescription = '''';
          };
        };
      };
    });
}
