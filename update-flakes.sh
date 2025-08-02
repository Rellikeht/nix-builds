#!/usr/bin/env sh

if which git-push-all >/dev/null; then
  GIT_PUSH=git-push-all
else
  GIT_PUSH='git push'
fi

git pull || exit 1

# hardcoded shit because I can't reliably
# parse that from flake.nix
for dir in \
    chuffed \
    minizinc \
    minizinc-ide-bin \
    pico-sdk \
    playit \
    playit-bin \
    scheme-langserver-bin \
    xinit-xsession; do
    cd "$dir" || exit 1
    nix flake update || exit 1
    git add flake.lock
    cd ..
done

git commit -m "started updating deps"
"$GIT_PUSH" || exit 1

nix flake update
git add flake.lock
git commit -m "updated deps"
"$GIT_PUSH" || exit 1

exit
