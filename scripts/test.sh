#!/usr/bin/env bash
set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT=$(dirname $(dirname $(realpath "$0")))
else
	ROOT=$(dirname $(dirname $(readlink -f $0)))
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
