#!/usr/bin/env sh

sed -nEz 's/(.*)(outputs = \{[^}]*\n)( *}:.*)/\2/p' flake.nix |
    sed '1,4d;s/^ *//;s/,.*$//' |
    xargs -d '\n' -I{} sh -c "
        ! [ -d '{}' ] && exit 0
        cd '{}'
        nix flake update
    "

nix flake update
git add .
