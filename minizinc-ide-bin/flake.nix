{
  description = "Binary build of minizinc ide with solvers";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/9c1bd826948a7";
    nixpkgs.url = "github:NixOS/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";
    pkg-linux-x64 = {
      url = "https://github.com/MiniZinc/MiniZincIDE/releases/download/2.8.5/MiniZincIDE-2.8.5-bundle-linux-x86_64.tgz";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    pkg-linux-x64,
  }: let
    systems = ["x86_64-linux"];
    flib = flakeUtils.lib;
  in
    flib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "minizinc-ide-bin-2.8.5";
      src = pkg-linux-x64;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          buildInputs = with pkgs; [
            qt6.qtbase
            qt6.qtwebsockets
            libglvnd
            util-linux
            gcc
            glibc

            zlib
            e2fsprogs
            gmpxx
          ];

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            qt6.wrapQtAppsHook
            coreutils
          ];

          sourceRoot = ".";
          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp -r ${src}/lib $out
            cp -r ${src}/plugins $out
            cp -r ${src}/share $out

            cp -r ${src}/bin $out
            # mkdir -p $out/bin
            # find ${src}/bin -executable -type f -print0 |\
            #   xargs -0 -I{} cp {} "$out/bin"

            runHook postInstall
          '';

          meta = with lib; {
            homepage = "https://www.minizinc.org/ide/";
            description = "Binary build of minizinc ide with solvers built in";
            license = licenses.mpl2;
            mainProgram = "minizinc";
            maintainers = ["Rellikeht"];
            platforms = platforms.linux;

            longDescription = '''';
          };
        };
      };
    });
}
