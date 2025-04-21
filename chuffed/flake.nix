{
  description = "Simple flake for building chuffed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    package = {
      url = "github:chuffed/chuffed";
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
      "aarch64-linux"
    ];
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "chuffed";
      src = package;
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
