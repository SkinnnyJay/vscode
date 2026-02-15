#!/usr/bin/env bash
set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT=$(dirname $(dirname $(realpath "$0")))
else
	ROOT=$(dirname $(dirname $(readlink -f $0)))
fi

DISPLAY_UNAVAILABLE=0
if [[ -z "${DISPLAY:-}" ]]; then
	DISPLAY_UNAVAILABLE=1
elif command -v xdpyinfo > /dev/null 2>&1 && ! xdpyinfo > /dev/null 2>&1; then
	DISPLAY_UNAVAILABLE=1
fi

if [[ "$OSTYPE" != "darwin"* ]] && [[ "$DISPLAY_UNAVAILABLE" == "1" ]] && command -v xvfb-run > /dev/null 2>&1 && [[ "${VSCODE_SKIP_XVFB_WRAPPER:-0}" != "1" ]]; then
	VSCODE_SKIP_XVFB_WRAPPER=1 xvfb-run -a "$0" "$@"
	exit $?
fi

cd $ROOT

if [[ "$OSTYPE" == "darwin"* ]]; then
	NAME=`node -p "require('./product.json').nameLong"`
	EXE_NAME=`node -p "require('./product.json').nameShort"`
	CODE="./.build/electron/$NAME.app/Contents/MacOS/$EXE_NAME"
else
	NAME=`node -p "require('./product.json').applicationName"`
	CODE=".build/electron/$NAME"
fi

VSCODECRASHDIR=$ROOT/.build/crashes
ELECTRON_TEST_ARGS=()
DISABLE_DEV_SHM_WORKAROUND=${VSCODE_TEST_DISABLE_DEV_SHM_WORKAROUND:-0}

# Headless Linux environments can hit /dev/shm pressure and fail dynamic imports.
# Keep the mitigation on by default for tests, with an opt-out for local debugging.
if [[ "$OSTYPE" != "darwin"* ]] && [[ "$DISABLE_DEV_SHM_WORKAROUND" != "1" ]]; then
	ELECTRON_TEST_ARGS+=(--disable-dev-shm-usage)
fi

# Node modules
test -d node_modules || npm i

# Get electron
if [[ -z "${VSCODE_SKIP_PRELAUNCH}" ]]; then
	npm run electron
fi

if [[ ! -x "$CODE" ]]; then
	echo "Electron binary '$CODE' missing, retrying setup..."
	npm run electron
fi

if [[ ! -x "$CODE" ]]; then
	echo "ERROR: Electron binary '$CODE' not found after setup."
	exit 1
fi

# Unit Tests
if [[ "$OSTYPE" == "darwin"* ]]; then
	cd $ROOT ; ulimit -n 4096 ; \
		ELECTRON_ENABLE_LOGGING=1 \
		"$CODE" \
		test/unit/electron/index.js --crash-reporter-directory=$VSCODECRASHDIR "${ELECTRON_TEST_ARGS[@]}" "$@"
else
	cd $ROOT ; \
		ELECTRON_ENABLE_LOGGING=1 \
		"$CODE" \
		test/unit/electron/index.js --crash-reporter-directory=$VSCODECRASHDIR "${ELECTRON_TEST_ARGS[@]}" "$@"
fi
