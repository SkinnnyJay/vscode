#!/usr/bin/env bash
# test-unit — Run fast unit tests (Node and optional browser); no Electron app required.
# Usage: ./scripts/test-unit.sh [--node-only|--browser]
#   Default: run Node unit tests only (mocha).
#   --node-only  Explicitly run only Node unit tests.
#   --browser     Also run browser unit tests (Playwright); installs Playwright if needed.
# Delegates to: npm run test-node [, npm run test-browser].
# Called by: make test-unit
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

RUN_NODE=true
RUN_BROWSER=false

for arg in "$@"; do
	case "$arg" in
		--node-only) RUN_BROWSER=false ;;
		--browser)   RUN_BROWSER=true ;;
	esac
done

echo "### Node unit tests"
npm run test-node

if [ "$RUN_BROWSER" = true ]; then
	echo "### Browser unit tests"
	npm run test-browser
fi
