{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    rust-overlay,
  }:
    flakeUtils.lib.eachDefaultSystem (
      system: let
        pylyzer-overlay = final: prev: {
          pylyzer = prev.pylyzer.override {
            rustPlatform = final.makeRustPlatform {
              rustc = final.pkgs.rust-bin.stable."1.75.0".default;
              cargo = final.pkgs.cargo;
            };
          };
        };

        overlays = [
          (import rust-overlay)
          pylyzer-overlay
        ];
        pkgs = import nixpkgs {inherit system overlays;};
        utils = import ../utils.nix {inherit pkgs;};
        packages = with pkgs; [pylyzer];
      in {
        packages.default = pkgs.pylyzer;
        devShells = {default = utils.defaultShell packages;};
      }
    );
}
