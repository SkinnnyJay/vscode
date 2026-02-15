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

if [[ "$OSTYPE" == "darwin"* ]]; then
	NAME="$(node -p "require('./product.json').nameLong")"
	EXE_NAME="$(node -p "require('./product.json').nameShort")"
	CODE="./.build/electron/$NAME.app/Contents/MacOS/$EXE_NAME"
else
	NAME="$(node -p "require('./product.json').applicationName")"
	CODE="./.build/electron/$NAME"
fi

if [[ ! -x "$CODE" ]]; then
	echo "Electron binary '$CODE' missing, retrying setup..."
	npm run electron
fi

if [[ ! -x "$CODE" ]]; then
	echo "ERROR: Electron binary '$CODE' not found after setup."
	exit 1
fi

npm run smoketest
