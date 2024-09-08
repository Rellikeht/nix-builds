{
  description = "Github release of scheme langserver";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = "https://github.com/ufo5260987423/scheme-langserver/releases/download/1.1.1/run";
      type = "file";
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
      pname = "scheme-langserver";
      version = "1.1.1";
      src = package;
    in {
      packages = {
        default = pkgs.stdenv.mkDerivation {
          inherit pname version system; # src;

          buildInputs = with pkgs; [
            glibc
            util-linux
          ];

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            binutils
            # gcc
          ];

          unpackPhase = ''
            # How the fuck this make shit work
            file ${src}
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp ${src} $out/bin/${pname}
            chmod +x $out/bin/${pname}
          '';

          meta = with lib; {
            homepage = "homepage";
            description = "Binary build of scheme-langserver from github";
            license = licenses.mit;
            mainProgram = pname;
            maintainers = ["Rellikeht"];
            platforms = platforms.linux;

            longDescription = '''';
          };
        };
      };
    });
}
