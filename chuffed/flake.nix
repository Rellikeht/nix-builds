{
  description = "Simple flake for building chuffed";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    chuffed = {
      url = github:chuffed/chuffed;
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    chuffed,
  }:
    flakeUtils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "chuffed";
      src = chuffed;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          CMAKE_MAKE_PROGRAM = "make -j $NIX_BUILD_CORES";

          nativeBuildInputs = with pkgs; [
            cmake
          ];

          meta = with nixpkgs.lib; {
            homepage = "https://github.com/chuffed/chuffed";
            description = "Chuffed solver";
          };
        };
      };
    });
}
