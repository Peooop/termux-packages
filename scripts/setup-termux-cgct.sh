#!/usr/bin/env bash
set -e -u

# Attention: this script is not tested, so there may be errors.

ARCH="$1"
REPO_URL="https://s3.amazonaws.com/termux-pacman.us/gpkg-dev"

if [ "$(id -u)" = "0" ]; then
	SUDO=""
else
	SUDO="sudo"
fi

. $(dirname "$(realpath "$0")")/properties.sh
$SUDO mkdir -p $TERMUX_PREFIX
$SUDO chown -R $(whoami) /data

if [ ! -d "$TERMUX_CACHE_DIR" ]; then
	mkdir -p "$TERMUX_CACHE_DIR"
fi

if [ -d "$TERMUX_PREFIX/glibc" ]; then
	rm -fr "$TERMUX_PREFIX/glibc"
fi

if [ ! -d "$CGCT_DIR" ]; then
	curl "$REPO_URL/x86_64/gpkg-dev.json" -o "$TERMUX_CACHE_DIR/cgct.json"
	for pkgname in cbt cgt; do
		filename=$(cat "$TERMUX_CACHE_DIR/cgct.json" | jq -r '."'$pkgname'"."FILENAME"')
		if [ ! -f "$TERMUX_CACHE_DIR/$filename" ]; then
			curl "$REPO_URL/x86_64/$filename" -o "$TERMUX_CACHE_DIR/$filename"
		fi
		tar xJf "$TERMUX_CACHE_DIR/$filename" -C / data
	done
fi

PACKAGES=""
PACKAGES+=" glibc"
PACKAGES+=" linux-api-headers"

curl "$REPO_URL/$ARCH/gpkg-dev.json" -o "$TERMUX_CACHE_DIR/pkgs.json"
for pkgname in $PACKAGES; do
	filename=$(cat "$TERMUX_CACHE_DIR/pkgs.json" | jq -r '."'$pkgname'"."FILENAME"')
	if [ ! -f "$TERMUX_CACHE_DIR/$filename" ]; then
		curl "$REPO_URL/$ARCH/$filename" -o "$TERMUX_CACHE_DIR/$filename"
	fi
	tar xJf "$TERMUX_CACHE_DIR/$filename" -C / data
done
