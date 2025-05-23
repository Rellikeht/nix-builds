{
  description = "Binary build of playit client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";

    # Shit is statically linked
    pkg-linux-x64 = {
      url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64";
      type = "file";
      flake = false;
    };

    pkg-linux-x86 = {
      url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-i686";
      type = "file";
      flake = false;
    };

    pkg-linux-a64 = {
      url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-aarch64";
      type = "file";
      flake = false;
    };

    pkg-linux-a32 = {
      url = "https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-armv7";
      type = "file";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    pkg-linux-x64,
    pkg-linux-x86,
    pkg-linux-a64,
    pkg-linux-a32,
  }: let
    systems = {
      "x86_64-linux" = pkg-linux-x64;
      "i686-linux" = pkg-linux-x86;
      "aarch64-linux" = pkg-linux-a64;
      "armv7l-linux" = pkg-linux-a32;
    };

    b = builtins;
    flib = flakeUtils.lib;
  in
    flib.eachSystem (b.attrNames systems) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      pname = "playit-bin";
      version = "0.15.26";
      src = systems.${system};
      mainProgram = "playit";
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit pname version system src;

          phases = ["installPhase"];
          installPhase = ''
            mkdir -p $out/bin
            cp ${src} $out/bin/${mainProgram}
            chmod +x $out/bin/${mainProgram}
          '';

          meta = with lib; {
            inherit mainProgram;
            homepage = "https://playit.gg/";
            description = "Binary release of playit agent";
            license = licenses.bsd2;
            maintainers = ["Rellikeht"];
            platforms = platforms.linux; # ???

            longDescription = '''';
          };
        };
      };
    });
}
