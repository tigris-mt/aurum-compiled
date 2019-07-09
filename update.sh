#!/bin/bash
set -ex

test -e update.sh

rm -rf /tmp/aurum-release
git clone --recursive "$HOME/.minetest/games/aurum" /tmp/aurum-release

git rm --cached -r .
git add update.sh
git clean -fxd
find --not -name .git "$T"
