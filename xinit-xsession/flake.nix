{
  description = "xsession running ~/.xinitrc";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
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
      lib = pkgs.lib;
      name = "xinit-xsession";
      src = self;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit name system src;

          phases = ["installPhase"];
          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/xsessions
            cp $src/xinitrcsession-helper $out/bin
            cp $src/xinitrc.desktop $out/share/xsessions
          '';

          meta = with lib; {
            homepage = "https://aur.archlinux.org/packages/xinit-xsession";
            description = "TODO";
            license = licenses.gpl3;
            # mainProgram = "";
            maintainers = ["Rellikeht"];
            platforms = platforms.linux;

            longDescription = '''';
          };
        };
      };
    });
}
