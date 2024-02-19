{
  description = "Binary version of minizinc with solvers";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      # url = "https://github.com/MiniZinc/MiniZincIDE/releases/download/2.8.3/MiniZincIDE-2.8.3-bundle-linux-x86_64.tgz";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    package,
  }: let
    systems = ["x86_64-linux"];
    flib = flakeUtils.lib;
  in
    flib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "minizinc";
      src = package;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          #           buildInputs = with pkgs; [
          #             mpfr
          #             zlib
          #           ];

          # nativeBuildInputs = with pkgs; [
          # ];

          meta = with lib; {
            homepage = "https://www.minizinc.org/";
            description = "Binary build of minizinc with solvers built in";
            # license = licenses.gpl3;
            mainProgram = "minizinc";
            maintainers = "Rellikeht";
            platforms = platforms.linux;

            longDescription = '''';
          };
        };
      };
    });
}
