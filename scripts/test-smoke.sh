#!/usr/bin/env bash
# test-smoke - Run smoke tests (launch app and basic sanity checks).
# Usage: ./scripts/test-smoke.sh
# Delegates to: npm run smoketest (builds smoke test and runs; may run electron).
# Called by: make test-smoke
# Prerequisite: compile and Electron build (e.g. make build && npm run electron once).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

source "$ROOT/scripts/electron-launcher-utils.sh"

maybe_reexec_with_xvfb "$0" "$@"

if [[ "$OSTYPE" == "darwin"* ]]; then
	NAME="$(node -p "require('./product.json').nameLong")"
	EXE_NAME="$(node -p "require('./product.json').nameShort")"
	CODE="./.build/electron/$NAME.app/Contents/MacOS/$EXE_NAME"
else
	NAME="$(node -p "require('./product.json').applicationName")"
	CODE="./.build/electron/$NAME"
fi

if ! ensure_electron_binary_with_retry "$CODE"; then
	exit 1
fi

npm run smoketest
