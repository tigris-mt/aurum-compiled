#!/bin/bash
set -e

REPO="https://github.com/tigris-mt/aurum"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

test -e update.sh

mkdir -p /tmp/aurum-release
pushd /tmp/aurum-release
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
	find /tmp/aurum-release -not -iwholename '*/.git*' "$@"
}

f -type d | while read n; do
	echo $n
done
