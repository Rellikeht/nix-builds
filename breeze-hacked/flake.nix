{
  description = "Breeze hacked cursors";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";
    package = {
      url = "github:clayrisser/breeze-hacked-cursor-theme";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    package,
  }: let
    flib = flakeUtils.lib;
    systems = flib.allSystems;
  in
    flib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "breeze-hacked";
      src = package;
      iconsDir = "$out/share/icons/";
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          # CMAKE_MAKE_PROGRAM = "make -j $NIX_BUILD_CORES";

          buildInputs = with pkgs; [
          ];

          nativeBuildInputs = with pkgs; [
            xorg.xcursorgen
            inkscape
            bat
            bash
            python312
          ];

          # TODO more colors, yay
          buildPhase = ''
            sed -i "s#./build.py#python build.py#" Makefile
            # shittiest workaround ever around fucking
            # python couldn't simply read $PATH
            sed -Ei "
            s/import Popen, ?(.*)/import \1/
            /from subprocess/aimport subprocess as subp\n\
            Popen = lambda *args, **kwargs: subp.Popen(*args, **kwargs, shell=True)
            " build.py
            make -j $NIX_BUILD_CORES build
          '';
          installPhase = ''
            mkdir -p ${iconsDir}
            cp -r Breeze_Hacked ${iconsDir}/
          '';

          meta = with lib; {
            homepage = "";
            description = "Breeze hacked cursor theme";
            # license = licenses.gpl3;
            mainProgram = "";
            maintainers = ["Rellikeht"];
            platforms = platforms.all;

            longDescription = '''';
          };
        };
      };
    });
}
