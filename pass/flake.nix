{
  description = "Pass password manager";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flakeUtils.url = github:numtide/flake-utils;
    package = {
      url = "https://git.zx2c4.com/password-store";
      flake = false;
    };

    dmenu.url = github:Rellikeht/dmenu;
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    package,
    dmenu,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
  in
    flakeUtils.lib.eachSystem [systems] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      name = "program";
      src = package;
    in {
      packages = {
        default = let
          passExtensions = import ./extensions {inherit pkgs;};

          env = extensions: let
            # TODO
            selected =
              [pass]
              ++ extensions passExtensions
              ++ lib.optional tombPluginSupport passExtensions.tomb;
          in
            buildEnv {
              name = "pass-env";
              paths = selected;
              nativeBuildInputs = [makeWrapper];
              buildInputs = lib.concatMap (x: x.buildInputs) selected;

              postBuild = ''
                files=$(find $out/bin/ -type f -exec readlink -f {} \;)
                if [ -L $out/bin ]; then
                  rm $out/bin
                  mkdir $out/bin
                fi

                for i in $files; do
                  if ! [ "$(readlink -f "$out/bin/$(basename $i)")" = "$i" ]; then
                    ln -sf $i $out/bin/$(basename $i)
                  fi
                done

                wrapProgram $out/bin/pass \
                  --set SYSTEM_EXTENSION_DIR "$out/lib/password-store/extensions"
              '';
              meta.mainProgram = "pass";
            };
        in
          pkgs.stdenv.mkDerivation {
            inherit name system src;

            # Some variables, what to do
            # x11Support
            # dmenuSupport
            # waylandSupport

            buildInputs = with pkgs;
              [
                coreutils
                findutils
                gnugrep
                gnused
                getopt
                tree
                gnupg
                openssl
                which
                openssh
                procps
                qrencode
                xclip
                xdotool

                # wl-clipboard
                # ydotool
                # dmenu-wayland
              ]
              ++ [dmenu.${system}.default];

            nativeBuildInputs = with pkgs;
              [
              ]
              ++ buildInputs;

            meta = with lib; {
              description = "Stores, retrieves, generates, and synchronizes passwords securely";
              homepage = "https://www.passwordstore.org/";
              license = licenses.gpl2Plus;
              mainProgram = "pass";
              maintainers = "Rellikeht";
              platforms = platforms.unix;

              longDescription = ''
                pass is a very simple password store that keeps passwords inside gpg2
                encrypted files inside a simple directory tree residing at
                ~/.password-store. The pass utility provides a series of commands for
                manipulating the password store, allowing the user to add, remove, edit,
                synchronize, generate, and manipulate passwords.
              '';
            };
          };
      };
    });
}
