{
  description = "Flake consisting of all programs in working state in this repo";

  inputs = {
    flakeUtils.url = github:numtide/flake-utils;
    minizinc.url = "./minizinc";
    minizinc-ide-bin.url = "./minizinc-ide-bin";
    chuffed.url = "./chuffed";
    breeze-hacked.url = "./breeze-hacked";
    scheme-langserver-bin.url = "./scheme-langserver-bin";
    playit-bin.url = "./playit-bin";
    dwm.url = github:Rellikeht/dwm;
    st.url = github:Rellikeht/st;
    tabbed.url = github:Rellikeht/tabbed;
    dmenu.url = github:Rellikeht/dmenu;
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    chuffed,
    minizinc,
    minizinc-ide-bin,
    breeze-hacked,
    scheme-langserver-bin,
    playit-bin,
    dwm,
    st,
    tabbed,
    dmenu,
  }: let
    b = builtins;
    systems = ["x86_64-linux" "aarch64-linux"];
    l64 = "x86_64-linux";
    getDefS = system: pkg: pkg.packages.${system}.default;

    packagesMulti = flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      pkgnames = [
        chuffed
        minizinc
        minizinc-ide-bin
        breeze-hacked
        scheme-langserver-bin
        playit-bin

        dwm
        st
        tabbed
        dmenu
      ];

      # TODO make this work
      # packages = builtins.map getDef pkgnames;
      getDef = getDefS system;
    in {
      # inherit packages;
      packages = {
        chuffed = getDef chuffed;
        minizinc = getDef minizinc;
        breeze-hacked = getDef breeze-hacked;
        dwm = getDef dwm;
        st = getDef st;
        tabbed = getDef tabbed;
        dmenu = getDef dmenu;
      };
    });

    packagesL64 =
      (let
        getDef = getDefS l64;
      in {
        minizinc-ide-bin = getDef minizinc-ide-bin;
        scheme-langserver-bin = getDef scheme-langserver-bin;
      })
      // packagesMulti.packages.${l64};
  in {
    packages = packagesMulti.packages // {${l64} = packagesL64;};
    utils = {
    };
  };
}
