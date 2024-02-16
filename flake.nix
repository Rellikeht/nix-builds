{
  description = "Flake consisting of all programs in working state in this repo";

  inputs = {
    flakeUtils.url = github:numtide/flake-utils;
    minizinc.url = "./minizinc";
    chuffed.url = "./chuffed";
    breeze-hacked.url = "./breeze-hacked";
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    minizinc,
    chuffed,
    breeze-hacked,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      getDef = pkg: pkg.packages.${system}.default;
    in {
      packages = {
        minizinc = getDef minizinc;
        breeze-hacked = getDef breeze-hacked;
        chuffed = getDef chuffed;
      };
    });
}
