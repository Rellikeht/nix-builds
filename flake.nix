{
  description = "Flake consisting of all programs in working state in this repo";

  inputs = {
    flakeUtils.url = github:numtide/flake-utils;
    minizinc.url = "./minizinc";
    minizinc-ide-bin.url = "./minizinc-ide-bin";
    chuffed.url = "./chuffed";
    breeze-hacked.url = "./breeze-hacked";
    dwm.url = github:Rellikeht/dwm;
    st.url = github:Rellikeht/st;
    tabbed.url = github:Rellikeht/tabbed;
    dmenu.url = github:Rellikeht/dmenu;
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    minizinc,
    minizinc-ide-bin,
    chuffed,
    breeze-hacked,
    dwm,
    st,
    tabbed,
    dmenu,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
  in
    flakeUtils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      pkgnames = [
        minizinc
        minizinc-ide-bin
        chuffed
        breeze-hacked
        dwm
        st
        tabbed
        dmenu
      ];

      getDef = pkg: pkg.packages.${system}.default;
      # TODO make this work
      # packages = builtins.map getDef pkgnames;
    in {
      # inherit packages;
      packages = {
        minizinc = getDef minizinc;
        minizinc-ide-bin = getDef minizinc-ide-bin;
        breeze-hacked = getDef breeze-hacked;
        chuffed = getDef chuffed;
        dwm = getDef dwm;
        st = getDef st;
        tabbed = getDef tabbed;
        dmenu = getDef dmenu;
      };
    });
}
