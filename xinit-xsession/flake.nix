{
  description = "~/.xinitrc can now run as xsession";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"

      "aarch64-linux"
      "armv7l-linux"
    ];
    flib = flakeUtils.lib;
  in
    flib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      name = "xinit-xsession";
      src = self;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          phases = ["installPhase"];
          installPhase = let
            sesDir = "$out/share/xsessions";
          in ''
            mkdir -p $out/bin
            mkdir -p ${sesDir}
            cp $src/xinitrcsession-helper $out/bin
            cp $src/xinitrc.desktop ${sesDir}
          '';

          passthru.providedSessions = ["xinitrc"];

          meta = with pkgs.lib; {
            homepage = "https://aur.archlinux.org/packages/xinit-xsession";
            description = "~/.xinitrc can now run as xsession";
            license = licenses.gpl3;
            maintainers = ["Rellikeht"];
            platforms = platforms.linux;
          };
        };
      };
    });
}
