#!/usr/bin/env bash
# test-e2e — Run end-to-end / integration-style tests.
# Usage: ./scripts/test-e2e.sh [args...]
# Delegates to: scripts/test-integration.sh (Electron integration tests).
# For web integration tests use: make test-web-integration.
# Called by: make test-e2e
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

"$SCRIPT_DIR/test-integration.sh" "$@"
