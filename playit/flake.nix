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
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          buildInputs = with pkgs; [
          ];

          nativeBuildInputs = with pkgs; [
            rustc
            cargo
          ];

          buildPhase = ''
            cargo run --release
          '';

          installPhase = ''
            ls $src
            mkdir -p $out/bin
          '';

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
