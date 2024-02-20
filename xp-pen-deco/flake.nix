{
  description = "Driver for XPPen Deco 01 V2";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      # This is probably too manual
      url = "https://www.xp-pen.com/download/file.html?id=1936&pid=440&ext=gz";
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
    ];
    description = description;
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "xp-pen-deco-01-v2-driver";
      src = package;
      dataDir = "var/lib/xppend1v2";
      exec = "PenTablet";
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          nativeBuildInputs = with pkgs; [
            libsForQt5.qt5.wrapQtAppsHook
            autoPatchelfHook
            makeWrapper
          ];

          dontBuild = true;
          dontWrapQtApps = true; # this is done manually

          buildInputs = with pkgs; [
            libusb1
            xorg.libX11
            xorg.libXtst
            xorg.libXi
            xorg.libXrandr
            xorg.libXinerama

            glibc
            libGL
            stdenv.cc.cc.lib
            libsForQt5.qt5.qtx11extras
          ];

          unpackPhase = "
            tar xzf ${src}
            mv XPPenLinux*/* .
            rm -r XPPen*
          ";

          installPhase = ''
            mkdir -p $out/bin
            cp -r App/* $out
            rm $out/usr/lib/pentablet/PenTablet.sh
            ln -s ../usr/lib/pentablet/PenTablet $out/bin/pentablet
          '';

          postFixup = ''
            makeWrapper $out/usr/lib/pentablet/PenTablet \
            $out/bin/pentablet \
            "''${qtWrapperArgs[@]}" \
            --run 'if [ "$EUID" -ne 0 ]; then echo "Please run as root."; exit 1; fi' \
            --run "
            if [ ! -d /${dataDir} ]
            then mkdir -p /${dataDir}
              cp -r $out/usr/lib/pentablet/conf /${dataDir}
              chmod u+w -R /${dataDir}
            fi
            "
          '';

          meta = with nixpkgs.lib; {
            homepage = "https://xp-pen.com/download/deco-01-v2.html";
            description = "XP Pen Deco 01 V2 driver";
            platforms = ["x86_64-linux"];
            sourceProvenance = with sourceTypes; [binaryNativeCode];
            # license = licenses.unfree;
          };
        };
      };
    });
}
