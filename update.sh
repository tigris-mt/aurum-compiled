#!/bin/bash
set -e

REPO="https://github.com/tigris-mt/aurum"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
T="/tmp/aurum-release"

test -e update.sh

mkdir -p "$T"
pushd "$T"
if [ ! -d .git ]; then
	git init
	git remote add origin "$REPO"
fi
git remote set-url origin "$REPO"
git fetch origin
git reset --hard origin/"$BRANCH"
git submodule update --init --recursive
git clean -fxd
popd

git rm --cached -r .
git add update.sh
git clean -fxd

f() {
	find "$T" -not -iwholename '*/.git*' -printf '%P\n' "$@"
}

f -type d | while read n; do
	mkdir -p "$n"
done

f -type f | while read n; do
	cp -RL $n .
done
