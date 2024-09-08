#!/usr/bin/env sh

find . -mindepth 2 -name 'flake.nix' -printf '%h\n' |
    grep -Ev '' |
    xargs -d '\n' -I{} 'sh -c "cd {} ; nix flake update"'

# NIX="nix run nixpkgs\#nix"
# alias nix=$NIX

# sed -nEz 's/(.*)(outputs = \{[^}]*\n)( *}:.*)/\2/p' flake.nix |
#     sed '1,4d;s/^ *//;s/,.*$//' |
#     xargs -d '\n' -I{} sh -c "
#     ! [ -d '{}' ] && exit 0
#     cd '{}'
#     rm flake.lock
#     $NIX flake update
#     $NIX flake lock
#     "

# rm flake.lock
# nix flake update
# nix flake lock
# git add .
