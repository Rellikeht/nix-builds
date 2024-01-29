{
  description = "pybind11 protobuf";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = github:pybind/pybind11_protobuf;
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    package,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "pybind11-protobuf";
      src = package;
      pkgPython = pkgs.python311;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          CMAKE_MAKE_PROGRAM = "make -j $NIX_BUILD_CORES";
          # TODO remove unneeded things

          buildInputs = with pkgs; [
            pkgPython.pkgs.pybind11
            #zlib
            protobuf
          ];

          nativeBuildInputs = with pkgs; [
            protobuf
            #bazel
            cmake
          ];

          # TODO meta
          meta = with lib; {
            #homepage = "homepage";
            #description = "description";
            # license = licenses.gpl3;
            #mainProgram = "programName";
            #maintainers = "Rellikeht";
            platforms = platforms.unix;

            longDescription = '''';
          };
        };
      };
    });
}
