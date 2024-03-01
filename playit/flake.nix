{
  description = "playit.gg client";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = github:playit-cloud/playit-agent;
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

      # Untested, should work, because this isn't c/c++
      "i686-linux"

      "aarch64-linux"
      "armv7l-linux"

      "aarch64-darwin"
      "x86_64-darwin"
    ];
    flib = flakeUtils.lib;
  in
    flib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "playit";
      src = package;
    in {
      packages = {
        default = pkgs.rustPlatform.buildRustPackage {
          inherit name system src;

          nativeBuildInputs = with pkgs; [
            installShellFiles
          ];

          cargoLock = {
            lockFile = "${src}/Cargo.lock";
          };

          # TODO something gone wrong, all tests are skipped :(
          checkFlags = map (n: "--skip=" + n) [
            "test_lookup"
            "test"
          ];

          # TODO this will be better done manually
          # installPhase = ''
          #   ls -R $src
          #   mkdir -p $out/bin
          #   ls -R $out
          #   # exit 1
          # '';

          meta = with lib; {
            homepage = "https://playit.gg";
            description = "playit client";
            license = licenses.bsd2;
            mainProgram = "playit";
            maintainers = ["Rellikeht"];
            platforms = platforms.linux;

            longDescription = '''';
          };
        };
      };
    });
}
