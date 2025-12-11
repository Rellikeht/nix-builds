{
  description = "hq build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    hq = {
        url = "github:MultisampledNight/hq";
        flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    hq,
  }: let
    b = builtins;
    flib = flakeUtils.lib;
  in
    flib.eachSystem flib.allSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "hq";
      src = hq;
      mainProgram = "hq";
    in {
      packages = {
        default = pkgs.rustPlatform.buildRustPackage {
          inherit name system src;

          cargoLock = {
            lockFile = "${src}/Cargo.lock";
          };

          meta = with lib; {
            inherit mainProgram;
            homepage = "https://github.com/MultisampledNight/hq";
            description = "Like jq, but for HTML.";
            license = licenses.mit;
            maintainers = ["Rellikeht"];
            platforms = platforms.linux;
            longDescription = '''';
          };
        };
      };
    });
}
