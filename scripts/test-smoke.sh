#!/usr/bin/env bash
# test-smoke — Run smoke tests (launch app and basic sanity checks).
# Usage: ./scripts/test-smoke.sh
# Delegates to: npm run smoketest (builds smoke test and runs; may run electron).
# Called by: make test-smoke
# Prerequisite: compile and Electron build (e.g. make build && npm run electron once).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

npm run smoketest
