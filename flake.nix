{
  description = "Flake consisting of all programs in working state in this repo";

  inputs = {
    flakeUtils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";

    dwm.url = "github:Rellikeht/dwm";
    st.url = "github:Rellikeht/st";
    tabbed.url = "github:Rellikeht/tabbed";
    dmenu.url = "github:Rellikeht/dmenu";
    svim.url = "github:Rellikeht/svim-comptools";

    chuffed.url = "./chuffed";
    minizinc.url = "./minizinc";
    playit.url = "./playit";

    playit-bin.url = "./playit-bin";
    scheme-langserver-bin.url = "./scheme-langserver-bin";
    minizinc-ide-bin.url = "./minizinc-ide-bin";

    breeze-hacked.url = "./breeze-hacked";
    xinit-xsession.url = "./xinit-xsession";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flakeUtils,
    dwm,
    st,
    tabbed,
    dmenu,
    svim,
    chuffed,
    minizinc,
    playit,
    playit-bin,
    scheme-langserver-bin,
    minizinc-ide-bin,
    breeze-hacked,
    xinit-xsession,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    getDefS = system: pkg: pkg.packages.${system}.default;
    l64 = "x86_64-linux";

    # TODO fuck this shit
    # pkgInputs = builtins.tail (builtins.tail (builtins.tail inputs));

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
        dwm = getDef dwm;
        st = getDef st;
        tabbed = getDef tabbed;
        dmenu = getDef dmenu;
        svim = getDef svim;

        chuffed = getDef chuffed;
        minizinc = getDef minizinc;
        playit = getDef playit;

        playit-bin = getDef playit-bin;

        breeze-hacked = getDef breeze-hacked;
        xinit-xsession = getDef xinit-xsession;
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

