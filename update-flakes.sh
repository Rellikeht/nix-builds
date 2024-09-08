#!/usr/bin/env sh

find . -mindepth 2 -name 'flake.nix' -printf '%h\n' |
    xargs -d '\n' -I{} sh -c 'cd "{}" ; nix flake update'
