{
  description = "Flake consisting of all programs in working state in this repo";

  inputs = {
    flakeUtils.url = github:numtide/flake-utils;
    nixpkgs.url = github:NixOS/nixpkgs;

    dwm.url = github:Rellikeht/dwm;
    st.url = github:Rellikeht/st;
    tabbed.url = github:Rellikeht/tabbed;
    dmenu.url = github:Rellikeht/dmenu;

    minizinc.url = "./minizinc";
    minizinc-ide-bin.url = "./minizinc-ide-bin";
    chuffed.url = "./chuffed";
    breeze-hacked.url = "./breeze-hacked";
    scheme-langserver-bin.url = "./scheme-langserver-bin";
    playit-bin.url = "./playit-bin";
  };

  outputs = inputs @ {
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
    systems = ["x86_64-linux" "aarch64-linux"];
    getDefS = system: pkg: pkg.packages.${system}.default;
    l64 = "x86_64-linux";

    # TODO fuck this shit
    pkgInputs = builtins.tail (builtins.tail (builtins.tail inputs));

    packagesMulti = flakeUtils.lib.eachSystem systems (system: let
      # pkgs = nixpkgs.legacyPackages.${system};
      # lib = pkgs.lib;
      getDef = getDefS system;
      # packages = builtins.listToAttrs (builtins.map
      #   (name: {
      #     inherit name;
      #     value = getDef name;
      #   })
      #   pkgInputs);
    in {
      # inherit packages;
      # });

      packages = {
        chuffed = getDef chuffed;
        minizinc = getDef minizinc;
        breeze-hacked = getDef breeze-hacked;
        playit-bin = getDef playit-bin;
      };
    });

    packagesL64 =
      (let
        getDef = getDefS l64;
      in {
        minizinc-ide-bin = getDef minizinc-ide-bin;
        scheme-langserver-bin = getDef scheme-langserver-bin;

        dwm = getDef dwm;
        st = getDef st;
        tabbed = getDef tabbed;
        dmenu = getDef dmenu;
      })
      // packagesMulti.packages.${l64};
    packages =
      (packagesMulti.packages)
      // {${l64} = packagesL64;};
  in {
    inherit packages;
    utils = {
    };
  };
}
# packages = flakeUtils.lib.eachSystem systems (system: let
#   packages = (
#     builtins.listToAttrs (builtins.map
#       (name: {
#         inherit name;
#         value = getDefS system name;
#       })
#       pkgInputs)
#   );
# in (builtins.trace packages packages));

