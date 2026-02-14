#!/usr/bin/env bash
# typecheck — Run TypeScript type checking (build and optionally main src).
# Usage: ./scripts/typecheck.sh
# Delegates to: cd build && npm run typecheck; optional compile-check-ts-native.
# Called by: make typecheck
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
cd "$ROOT"

echo "Typecheck (build)..."
(cd build && npm run typecheck) || true
echo "Typecheck (src, native TS)..."
npm run compile-check-ts-native || true
echo "Typecheck finished."
